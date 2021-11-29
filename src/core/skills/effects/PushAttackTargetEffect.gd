class_name PushAttackTargetEffect, "res://assets/editor/pushattack_effect.png"
extends SkillEffectWrapper


class _PushData:
	var actor: Actor = null
	var direction: Vector2
	var real_distance: int
	var end_cell: Vector2
	var hit_wall: bool
	var is_instakill: bool
	var blocking_actors := []

	func _init(max_distance: int, block_damages_allies_only: bool,
			target_cell: Vector2, source_cell: Vector2, map: Map) -> void:
		actor = map.get_actor_on_cell(target_cell)
		_set_push_direction(source_cell)
		_set_real_distance_and_end_cell(map, max_distance)
		_set_blocking_actors(map, block_damages_allies_only)


	func _set_push_direction(source_cell: Vector2) -> void:
		var pushed_cell := TileGeometry.get_closest_rect_cell(
				source_cell, actor.cell_rect)
		direction = Directions.normalized_direction(pushed_cell - source_cell)


	func _set_real_distance_and_end_cell(map: Map, max_distance: int) -> void:
		real_distance = 0
		hit_wall = false

		var distance_cost := max_distance
		var next_cell := actor.origin_cell

		while distance_cost > 0:
			next_cell += direction
			if map.actor_can_be_pushed_into_cell(actor, next_cell):
				real_distance += 1
				distance_cost -= map.get_cell_push_cost(next_cell, actor)
			else:
				hit_wall = true
				break

		end_cell = actor.origin_cell + (direction * real_distance)
		is_instakill = not map.actor_can_enter_cell(actor, end_cell)

		if is_instakill and (actor.faction == Actor.Faction.PLAYER):
			# Don't actually instakill player characters
			while real_distance > 0:
				real_distance -= 1
				end_cell -= direction
				if map.actor_can_enter_cell(actor, end_cell):
					break


	func _set_blocking_actors(map: Map, block_damages_allies_only: bool) \
			-> void:
		blocking_actors = []

		var actor_rect := actor.get_cell_rect_at_cell(end_cell)
		var direction_type := Directions.get_closest_direction_type(direction)
		var adj_cells := TileGeometry.get_rect_side_cells(actor_rect,
				direction_type, 1)

		var other_actors := map.get_actors_on_cells(adj_cells)
		for a in other_actors:
			var other_actor := a as Actor
			if not block_damages_allies_only \
					or (other_actor.faction == actor.faction):
				blocking_actors.append(other_actor)


const _SPEED := 7.0 # Cells per second
const _LAND_HIT_DIST := 0.25
const _BLOCK_HIT_DIST := 0.5

export var max_distance := 1
export var block_damages_allies_only := true


func get_target_info(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	var result :=  TargetingData.TargetInfo.new()

	var push_data := _PushData.new(max_distance, block_damages_allies_only,
			target_cell, source_cell, map)

	# AOE

	var visible_end_cell := push_data.end_cell
	if not push_data.blocking_actors.empty():
		visible_end_cell += push_data.direction

	var push_aoe := TileGeometry.get_thick_line(push_data.actor.origin_cell,
			visible_end_cell, push_data.actor.size)
	for c in push_aoe:
		result.aoe[c] = true

	# Damage

	var damage: int
	if push_data.is_instakill:
		if push_data.actor.faction == Actor.Faction.PLAYER:
			var attack := source_actor.stats.attack * 3
			damage = push_data.actor.stats.damage_from_attack(attack)
		else:
			damage = push_data.actor.stats.stamina
	else:
		var attack := source_actor.stats.attack
		if push_data.hit_wall:
			attack *= 2
		damage = push_data.actor.stats.damage_from_attack(attack)

	result.predicted_damage[push_data.actor] = -damage

	for a in push_data.blocking_actors:
		var blocking_actor := a as Actor
		var other_damage := blocking_actor.stats.damage_from_attack(
				source_actor.stats.attack)
		assert(not result.predicted_damage.has(blocking_actor))
		result.predicted_damage[blocking_actor] = -other_damage

	# After push

	push_data.actor.virtual_origin_cell = push_data.end_cell
	var landing_info := _get_child_target_info(push_data.end_cell, source_cell,
			source_actor, map)
	result.add(landing_info)

	return result


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map):
	var push_data := _PushData.new(max_distance, block_damages_allies_only,
			target_cell, source_cell, map)

	var actor := push_data.actor

	if not map.actor_can_enter_cell(actor, push_data.end_cell):
		actor.stats.instant_kill(push_data.direction, false)
	else:
		actor.stats.take_damage(source_actor.stats.attack,
			push_data.direction, false)
	actor.play_hit_sound()

	var main_offset := push_data.end_cell - actor.origin_cell

	var offset := main_offset
	if push_data.hit_wall:
		offset += push_data.direction * _BLOCK_HIT_DIST
	elif actor.stats.is_alive:
		offset += push_data.direction * _LAND_HIT_DIST

	yield(
		actor.animate_offset(
			offset, push_data.real_distance / _SPEED,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT),
		"completed"
	)

	var other_attack_waiter := _hit_blocking_actors(push_data,
			source_actor.stats.attack)

	if actor.stats.is_alive and (push_data.hit_wall):
		actor.stats.take_damage(source_actor.stats.attack,
				-push_data.direction, false)
		actor.play_hit_sound()

	actor.origin_cell = push_data.end_cell
	actor.cell_offset -= main_offset

	if actor.stats.is_alive:
		assert(actor.cell_offset != Vector2.ZERO)
		yield(
			actor.animate_offset(
				Vector2.ZERO, _BLOCK_HIT_DIST / _SPEED,
				Tween.TRANS_QUAD, Tween.EASE_OUT),
			"completed"
		)
	elif push_data.hit_wall:
		yield(actor.animate_death(-push_data.direction, false), "completed")
	else:
		yield(actor.animate_death(push_data.direction, false), "completed")

	if actor.animating:
		yield(actor, "animation_finished")
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
