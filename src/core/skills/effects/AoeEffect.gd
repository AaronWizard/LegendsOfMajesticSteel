class_name AoeEffect, "res://assets/editor/aoe_effect.png"
extends SkillEffectWrapper

enum TargetType { ALL_CELLS, ALL_ACTORS, ENEMIES, ALLIES }

export var aoe: Resource
export(TargetType) var target_type := TargetType.ALL_CELLS
export var source_is_aoe_target := true


func get_aoe(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Array:
	var result := {}

	var base_aoe := _get_base_aoe(target_cell, source_cell, source_actor, map)
	for b in base_aoe:
		var b_cell := b as Vector2
		result[b_cell] = true

	var targets := _get_targets_from_base(base_aoe, source_actor.faction, map)
	for t in targets:
		var aoe_target_cell := t as Vector2
		var aoe_source_cell := _get_aoe_source_cell(target_cell, source_cell)
		var child_aoe := _child_aoe(aoe_target_cell,
				aoe_source_cell, source_actor, map)
		for c in child_aoe:
			var c_cell := c as Vector2
			result[c_cell] = true

	return result.keys()


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var targets := _get_targets(target_cell, source_cell, source_actor, map)
	for t in targets:
		var aoe_target_cell := t as Vector2
		var aoe_source_cell := _get_aoe_source_cell(target_cell, source_cell)
		var child_damages := _predict_child_damage(
				aoe_target_cell, aoe_source_cell, source_actor, map)
		for a in child_damages:
			var actor := a as Actor
			var damage := child_damages[actor] as int
			if not result.has(actor):
				result[actor] = 0
			result[actor] += damage

	return result


func predict_conditions(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var targets := _get_targets(target_cell, source_cell, source_actor, map)
	for t in targets:
		var aoe_target_cell := t as Vector2
		var aoe_source_cell := _get_aoe_source_cell(target_cell, source_cell)
		var child_conditions := _predict_child_conditions(
				aoe_target_cell, aoe_source_cell, source_actor, map)
		for a in child_conditions:
			var actor := a as Actor
			var conditions := child_conditions[actor] as Array
			if not result.has(actor):
				result[actor] = []
			(result[actor] as Array).append_array(conditions)

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
					target_cell, source_cell)
			var child_effect := get_child(index) as SkillEffect

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


func _get_aoe_source_cell(effect_target_cell: Vector2,
		effect_source_cell: Vector2) -> Vector2:
	var result := effect_source_cell
	if source_is_aoe_target:
		result = effect_target_cell
	return result
