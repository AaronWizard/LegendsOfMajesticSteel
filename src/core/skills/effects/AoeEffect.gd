tool
class_name AoeEffect, "res://assets/editor/aoe_effect.png"
extends SkillEffectWrapper

enum TargetType { ALL_CELLS, ALL_ACTORS, ENEMIES, ALLIES }
enum ChildEffectSourceCellType {
		EFFECT_SOURCE_CELL, EFFECT_TARGET_CELL, AOE_TARGET_CELL }
enum ChildEffectDelaySortType { FROM_EFFECT_SOURCE, FROM_EFFECT_TARGET }

export var aoe: Resource
export(TargetType) var target_type := TargetType.ALL_CELLS
export(ChildEffectSourceCellType) var child_effect_source_cell \
		:= ChildEffectSourceCellType.AOE_TARGET_CELL

export(ChildEffectDelaySortType) var child_effect_delay_sort_type \
		:= ChildEffectDelaySortType.FROM_EFFECT_TARGET
export var child_effect_delay_speed := 0.0 # Tiles per second


func get_target_info(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	var result :=  TargetingData.TargetInfo.new()

	var base_aoe := _get_base_aoe(target_cell, source_cell, source_actor, map)
	for b in base_aoe:
		result.aoe[b] = true

	var targets := _get_targets_from_base(base_aoe, source_actor.faction, map)

	for t in targets:
		var aoe_target_cell := t as Vector2
		var aoe_source_cell := _get_aoe_source_cell(
				aoe_target_cell, target_cell, source_cell)
		var child_target_info := _get_child_target_info(
				aoe_target_cell, aoe_source_cell, source_actor, map)
		result.add(child_target_info)

	return result


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map):
	assert(get_child_count() == 1)

	var targets := _get_targets(target_cell, source_cell, source_actor, map)
	if not targets.empty():
		var main_effect := _child_effect()
		for _i in range(1, targets.size()):
			var new_child := main_effect.duplicate()
			add_child(new_child)

		assert(get_child_count() == targets.size())

		var waiter := SignalWaiter.new()
		for i in range(targets.size()):
			var index := i as int
			var aoe_target_cell := targets[index] as Vector2
			var aoe_source_cell := _get_aoe_source_cell(
					aoe_target_cell, target_cell, source_cell)
			var child_effect := get_child(index) as SkillEffect

			var delay := _get_delay(
					aoe_target_cell, target_cell, source_cell, map)
			child_effect.delay = delay

			child_effect.run(aoe_target_cell, aoe_source_cell,
					source_actor, map)
			assert(child_effect.running)
			waiter.wait_for_signal(child_effect, "finished")

		if waiter.waiting:
			yield(waiter, "finished")

		while get_child_count() > 1:
			var new_child := get_children().back() as Node
			remove_child(new_child)
			new_child.queue_free()

	assert(get_child_count() == 1)


func _get_base_aoe(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Array:
	var aoe_obj := aoe as SkillAOE
	return aoe_obj.get_aoe(target_cell, source_cell, source_actor, map)


func _get_targets_from_base(base_aoe: Array, source_actor_faction: int,
		map: Map) -> Array:
	var result := []

	if target_type == TargetType.ALL_CELLS:
		result = base_aoe
	else:
		var actors := map.get_actors_on_cells(base_aoe)
		for a in actors:
			var actor := a as Actor
			var include := true
			match target_type:
				TargetType.ENEMIES:
					include = actor.faction != source_actor_faction
				TargetType.ALLIES:
					include = actor.faction == source_actor_faction
			if include:
				result.append(actor.origin_cell)

	return result


func _get_targets(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Array:
	var base_aoe := _get_base_aoe(target_cell, source_cell, source_actor, map)
	var result := _get_targets_from_base(base_aoe, source_actor.faction, map)
	return result


func _get_aoe_source_cell(aoe_target_cell: Vector2, effect_target_cell: Vector2,
		effect_source_cell: Vector2) -> Vector2:
	var result: Vector2
	match child_effect_source_cell:
		ChildEffectSourceCellType.EFFECT_SOURCE_CELL:
			result = effect_source_cell
		ChildEffectSourceCellType.EFFECT_TARGET_CELL:
			result = effect_target_cell
		_:
			result = aoe_target_cell
	return result


func _get_delay(aoe_target_cell: Vector2, effect_target_cell: Vector2,
		effect_source_cell: Vector2, map: Map) -> float:
	var result := 0.0

	if child_effect_delay_speed > 0:
		var start: Vector2
		match child_effect_delay_sort_type:
			ChildEffectDelaySortType.FROM_EFFECT_SOURCE:
				start = effect_source_cell
			_:
				start = effect_target_cell
		var end: Vector2
		match target_type:
			TargetType.ALL_CELLS:
				end = aoe_target_cell
			_:
				var actor := map.get_actor_on_cell(aoe_target_cell)
				assert(actor != null)
				end = actor.center_cell
		var dist := end.distance_to(start)
		result = dist / child_effect_delay_speed

	return result
