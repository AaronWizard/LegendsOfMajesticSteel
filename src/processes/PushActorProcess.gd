class_name PushActorProcess
extends Process

const _SPEED := 10 # Tiles per second
const _HIT_DIST := 0.25

var actor: Actor
var map: Map
var attack: int
var direction: int
var distance: int

var _dir_v: Vector2


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
	var real_distance := _get_real_distance()
	var final_cell := actor.origin_cell + (_dir_v * real_distance)

	var real_attack := attack
	if real_distance < distance:
		real_attack *= 2

	actor.stats.take_damage(real_attack)

	if real_distance == 0:
		yield(_hit_only(), "completed")
	else:
		actor.set_pose(Actor.Pose.REACT)

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


func _get_real_distance() -> int:
	var result := 0

	var dir := Directions.get_vector(direction)
	for i in range(1, distance + 1):
		if map.actor_can_enter_cell(actor, actor.origin_cell + (dir * i)):
			result += 1
		else:
			break

	return result


func _hit_only() -> void:
	if actor.is_alive:
		actor.animate_hit(_dir_v)
		yield(actor, "hit_reaction_finished")
	else:
		actor.animate_death(_dir_v)
		yield(actor, "died")
