class_name PushAttackTargetEffect, "res://assets/editor/pushattack_effect.png"
extends SkillEffectWrapper


class _PushData:
	var actor: Actor = null
	var direction: Vector2
	var real_distance: int
	var end_cell: Vector2
	var blocking_actors := []

	func _init(max_distance: int, block_damages_allies_only: bool,
			target_cell: Vector2, source_cell: Vector2, map: Map) -> void:
		actor = map.get_actor_on_cell(target_cell)
		direction = _get_push_direction(source_cell)
		real_distance = _get_real_distance(map, max_distance)
		end_cell = _get_end_cell()
		blocking_actors = _get_blocking_actors(map, block_damages_allies_only)


	func _get_push_direction(source_cell: Vector2) -> Vector2:
		var pushed_cell := TileGeometry.get_closest_rect_cell(
				source_cell, actor.cell_rect)
		var result := Directions.normalized_direction(pushed_cell - source_cell)
		return result


	func _get_real_distance(map: Map, max_distance: int) -> int:
		var result := 0

		var next_cell := actor.origin_cell
		for _i in range(1, max_distance + 1):
			next_cell += direction
			if map.actor_can_enter_cell(actor, next_cell):
				result += 1
			else:
				break

		return result


	func _get_end_cell() -> Vector2:
		return actor.origin_cell + (direction * real_distance)


	func _get_blocking_actors(map: Map, block_damages_allies_only: bool) \
			-> Array:
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


const _SPEED := 7.0 # Cells per second
const _LAND_HIT_DIST := 0.25
const _BLOCK_HIT_DIST := 0.5

export var max_distance := 1
export var block_damages_allies_only := true


func get_aoe(target_cell: Vector2, source_cell: Vector2,
		_source_actor: Actor, map: Map) -> Array:
	var push_data := _PushData.new(max_distance, block_damages_allies_only,
			target_cell, source_cell, map)
	if not push_data.blocking_actors.empty():
		push_data.end_cell += push_data.direction

	var result := TileGeometry.get_thick_line(push_data.actor.origin_cell,
			push_data.end_cell, push_data.actor.rect_size)
	return result


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var push_data := _PushData.new(max_distance, block_damages_allies_only,
			target_cell, source_cell, map)

	var attack := source_actor.stats.attack
	if push_data.real_distance < max_distance:
		attack *= 2
	var damage := push_data.actor.stats.damage_from_attack(attack)
	result[push_data.actor] = -damage

	for a in push_data.blocking_actors:
		var blocking_actor := a as Actor
		var other_damage := blocking_actor.stats.damage_from_attack(
				source_actor.stats.attack)
		assert(not result.has(blocking_actor))
		result[blocking_actor] = -other_damage

	return result


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map):
	var push_data := _PushData.new(max_distance, block_damages_allies_only,
			target_cell, source_cell, map)

	assert(map.actor_can_enter_cell(push_data.actor, push_data.end_cell))

	push_data.actor.stats.take_damage(source_actor.stats.attack, push_data.direction, false)
	push_data.actor.play_hit_sound()

	var main_offset := push_data.end_cell - push_data.actor.origin_cell

	var offset := main_offset
	if push_data.real_distance < max_distance:
		offset += push_data.direction * _BLOCK_HIT_DIST
	elif push_data.actor.stats.is_alive:
		offset += push_data.direction * _LAND_HIT_DIST

	yield(
		push_data.actor.animate_offset(
			offset, push_data.real_distance / _SPEED,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
		"completed"
	)

	var other_attack_waiter := _hit_blocking_actors(push_data,
			source_actor.stats.attack)

	if push_data.actor.stats.is_alive \
			and (push_data.real_distance < max_distance):
		push_data.actor.stats.take_damage(source_actor.stats.attack,
				-push_data.direction, false)
		push_data.actor.play_hit_sound()

	push_data.actor.origin_cell = push_data.end_cell
	push_data.actor.cell_offset -= main_offset

	if push_data.actor.stats.is_alive:
		assert(push_data.actor.cell_offset != Vector2.ZERO)
		yield(
			push_data.actor.animate_offset(
				Vector2.ZERO, _BLOCK_HIT_DIST / _SPEED,
				Tween.TRANS_QUAD, Tween.EASE_OUT),
			"completed"
		)
	elif push_data.real_distance < max_distance:
		yield(push_data.actor.animate_death(-push_data.direction, false),
				"completed")
	else:
		yield(push_data.actor.animate_death(push_data.direction, false),
				"completed")

	if push_data.actor.animating:
		yield(push_data.actor, "animation_finished")
	if other_attack_waiter.waiting:
		yield(other_attack_waiter, "finished")

	var landing_state = _run_child_effect(push_data.end_cell, source_cell,
			source_actor, map)
	if landing_state is GDScriptFunctionState:
		yield(landing_state, "completed")


func _hit_blocking_actors(push_data: _PushData, attack: int) -> SignalWaiter:
	var waiter := SignalWaiter.new()

	var other_actors := push_data.blocking_actors
	for a in other_actors:
		var other_actor := a as Actor
		other_actor.stats.take_damage(attack, push_data.direction)
		waiter.wait_for_signal(other_actor, "animation_finished")

	return waiter
