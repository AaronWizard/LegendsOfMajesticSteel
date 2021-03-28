class_name PushActor
extends Process

const _SPEED := 8 # Tiles per second
const _HIT_DIST := 0.25

var actor: Actor
var map: Map
var attack: int
var direction: int
var distance: int

var _dir_v: Vector2


static func get_real_distance(pushed_actor: Actor, actor_map: Map,
		push_direction: int, max_distance: int) -> int:
	var result := 0

	var dir := Directions.get_vector(push_direction)
	for i in range(1, max_distance + 1):
		if actor_map.actor_can_enter_cell(
				pushed_actor, pushed_actor.origin_cell + (dir * i)):
			result += 1
		else:
			break

	return result


static func get_blocking_actors(pushed_actor: Actor, actor_map: Map,
		push_direction: int, push_distance: int) -> Array:
	var result := []

	var dir := Directions.get_vector(push_direction)
	var end_cell := pushed_actor.origin_cell + (dir * push_distance)
	var actor_rect := pushed_actor.get_cell_rect_at_cell(end_cell)
	var adj_cells := TileGeometry.get_rect_side_cells(actor_rect,
			push_direction, 1)

	var other_actors := actor_map.get_actors_on_cells(adj_cells)
	for a in other_actors:
		var other_actor := a as Actor
		if other_actor.faction == pushed_actor.faction:
			result.append(other_actor)

	return result


func _init(new_actor: Actor, new_map: Map, new_attack: int,
		new_direction: int, new_distance: int) -> void:
	actor = new_actor
	map = new_map
	attack = new_attack
	direction = new_direction
	distance = new_distance
	assert(distance > 0)

	_dir_v = Directions.get_vector(direction)


func _run_self() -> void:
	var real_distance := get_real_distance(actor, map, direction, distance)
	var final_cell := actor.origin_cell + (_dir_v * real_distance)

	var real_attack := attack
	if real_distance < distance:
		real_attack *= 2

	if real_distance == 0:
		_hit_other_actors(real_distance)
		_hit_actor(actor, real_attack)
	else:
		actor.stats.take_damage(real_attack)
		actor.set_pose(Actor.Pose.REACT)
		actor.play_hit_sound()

		actor.cell_offset = actor.origin_cell - final_cell
		actor.origin_cell = final_cell

		var push_anim_dist := real_distance + _HIT_DIST
		var push_anim_offset := _dir_v * _HIT_DIST

		yield(
			actor.animate_offset(
					push_anim_offset, push_anim_dist / _SPEED,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT),
			"completed"
		)

		_hit_other_actors(real_distance)
		_finish_hitting_target(real_distance)


func _finish_hitting_target(real_distance: int) -> void:
	if not actor.is_alive:
		var fall_dir := _dir_v
		if real_distance < distance:
			fall_dir *= -1
		actor.animate_death(fall_dir)
		yield(actor, "died")
	else:
		yield(
			actor.animate_offset(
					Vector2.ZERO, _HIT_DIST / _SPEED,
					Tween.TRANS_SINE, Tween.EASE_IN_OUT),
			"completed"
		)
		actor.reset_pose()


func _hit_actor(hit_actor: Actor, hit_attack: int) -> void:
	var damage_process := DamageActor.new(hit_actor, map, hit_attack, _dir_v)
	children.append(damage_process)


func _hit_other_actors(real_distance: int) -> void:
	if real_distance < distance:
		# Pushed actor is already adjacent to hit actors,
		# so pass 0 to get_blocking_actors for push distance
		var other_actors := get_blocking_actors(actor, map, direction, 0)
		for a in other_actors:
			var hit_actor := a as Actor
			var damage_process := DamageActor.new(
					hit_actor, map, attack, _dir_v)
			children.append(damage_process)
