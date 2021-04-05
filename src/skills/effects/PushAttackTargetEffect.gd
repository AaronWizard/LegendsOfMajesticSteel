class_name PushAttackTargetEffect, "res://assets/editor/pushattack_effect.png"
extends SkillEffect

const _SPEED := 7.0 # Cells per second
const _LAND_HIT_DIST := 0.25
const _BLOCK_HIT_DIST := 0.5

export var max_distance := 1
export var block_damages_allies_only := true


func get_aoe(target_cell: Vector2, source_cell: Vector2,
		_source_actor: Actor, map: Map) -> Array:
	var actor := map.get_actor_on_cell(target_cell)
	var direction := _get_push_direction(actor, source_cell)
	var real_distance := _get_real_distance(actor, map, direction)

	var end_cell := _get_end_cell(actor, direction, real_distance)
	var blocking_actors := _get_blocking_actors(actor, map, direction, end_cell)
	if not blocking_actors.empty():
		end_cell += direction

	var result := TileGeometry.get_thick_line(
			actor.origin_cell, end_cell, actor.rect_size)
	return result


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var actor := map.get_actor_on_cell(target_cell)
	var direction := _get_push_direction(actor, source_cell)
	var real_distance := _get_real_distance(actor, map, direction)

	var end_cell := _get_end_cell(actor, direction, real_distance)
	var blocking_actors := _get_blocking_actors(actor, map, direction, end_cell)

	var attack := source_actor.stats.attack
	if not blocking_actors.empty():
		attack *= 2
	var damage := actor.stats.damage_from_attack(attack)
	result[actor] = -damage

	for a in blocking_actors:
		var blocking_actor := a as Actor
		var other_damage := blocking_actor.stats.damage_from_attack(
				source_actor.stats.attack)
		assert(not result.has(blocking_actor))
		result[blocking_actor] = -other_damage

	return result


static func _get_end_cell(actor: Actor, direction: Vector2, distance: int) \
		-> Vector2:
	return actor.origin_cell + (direction * distance)


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map):
	var actor := map.get_actor_on_cell(target_cell)
	var direction := _get_push_direction(actor, source_cell)

	var real_distance := _get_real_distance(actor, map, direction)
	var end_cell := _get_end_cell(actor, direction, real_distance)

	assert(map.actor_can_enter_cell(actor, end_cell))

	actor.stats.take_damage(source_actor.stats.attack, direction, false)

	var main_offset := end_cell - actor.origin_cell

	var offset := main_offset
	if real_distance < max_distance:
		offset += direction * _BLOCK_HIT_DIST
	elif actor.is_alive:
		offset += direction * _LAND_HIT_DIST

	yield(
		actor.animate_offset(
			offset, real_distance / _SPEED,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
		"completed"
	)

	var other_attack_waiter := _hit_blocking_actors(actor, map, direction,
		end_cell, source_actor.stats.attack)

	if actor.is_alive and (real_distance < max_distance):
		actor.stats.take_damage(source_actor.stats.attack, -direction, false)

	actor.origin_cell = end_cell
	actor.cell_offset -= main_offset

	if actor.is_alive:
		assert(actor.cell_offset != Vector2.ZERO)
		yield(
			actor.animate_offset(
				Vector2.ZERO, _BLOCK_HIT_DIST / _SPEED,
				Tween.TRANS_QUAD, Tween.EASE_OUT),
			"completed"
		)
	elif real_distance < max_distance:
		actor.animate_death(-direction)
	else:
		actor.animate_death(direction)

	if actor.animating:
		yield(actor, "animation_finished")
	if other_attack_waiter.waiting:
		yield(other_attack_waiter, "finished")


func _get_push_direction(actor: Actor, source_cell: Vector2) -> Vector2:
	var pushed_cell := TileGeometry.get_closest_rect_cell(
			source_cell, actor.cell_rect)
	var result := Directions.normalized_direction(pushed_cell - source_cell)
	return result


func _get_real_distance(actor: Actor, map: Map, direction: Vector2) -> int:
	var result := 0

	var next_cell := actor.origin_cell
	for _i in range(1, max_distance + 1):
		next_cell += direction
		if map.actor_can_enter_cell(actor, next_cell):
			result += 1
		else:
			break

	return result


func _get_blocking_actors(actor: Actor, map: Map, direction: Vector2,
		end_cell: Vector2) -> Array:
	var result := []

	var actor_rect := actor.get_cell_rect_at_cell(end_cell)
	var direction_type := Directions.get_closest_direction_type(direction)
	var adj_cells := TileGeometry.get_rect_side_cells(actor_rect,
			direction_type, 1)

	var other_actors := map.get_actors_on_cells(adj_cells)
	for a in other_actors:
		var other_actor := a as Actor
		if not block_damages_allies_only \
				or (other_actor.faction == actor.faction):
			result.append(other_actor)

	return result


func _hit_blocking_actors(actor: Actor, map: Map, direction: Vector2,
		end_cell: Vector2, attack: int) -> SignalWaiter:
	var waiter := SignalWaiter.new()

	var other_actors := _get_blocking_actors(actor, map, direction, end_cell)
	for a in other_actors:
		var other_actor := a as Actor
		other_actor.stats.take_damage(attack, direction)
		waiter.wait_for_signal(other_actor, "animation_finished")

	return waiter
