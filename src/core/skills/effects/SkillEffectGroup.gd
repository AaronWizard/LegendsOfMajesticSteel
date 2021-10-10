tool
class_name SkillEffectGroup, "res://assets/editor/skilleffectgroup.png"
extends SkillEffect

enum GroupType { GROUP, SEQUENCE }

export(GroupType) var group_type := GroupType.GROUP


func _get_configuration_warning() -> String:
	var result := ""

	for c in get_children():
		if not (c is SkillEffect):
			result = "Child nodes must all be SkillEffects"
			break

	return result


func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := {}
	for e in get_children():
		var effect := e as SkillEffect
		var aoe := effect.get_aoe(target_cell, source_cell, source_actor, map)
		for c in aoe:
			var cell := c as Vector2
			result[cell] = true
	return result.keys()


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}
	for e in get_children():
		var effect := e as SkillEffect
		var effect_damages := effect.predict_damage(
				target_cell, source_cell, source_actor, map)
		for a in effect_damages:
			var actor := a as Actor
			var damage := effect_damages[actor] as int
			if not result.has(actor):
				result[actor] = 0
			result[actor] += damage
	return result


func predict_conditions(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}
	for e in get_children():
		var effect := e as SkillEffect
		var effect_conditions := effect.predict_conditions(
				target_cell, source_cell, source_actor, map)
		for a in effect_conditions:
			var actor := a as Actor
			var conditions := effect_conditions[actor] as Array
			if not result.has(actor):
				result[actor] = []
			(result[actor] as Array).append_array(conditions)
	return result


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	var waiter := SignalWaiter.new()

	for c in get_children():
		var child := c as SkillEffect
		child.run(target_cell, source_cell, source_actor, map)
		if group_type == GroupType.SEQUENCE:
			yield(child, "finished")
		else:
			assert(child.running)
			waiter.wait_for_signal(child, "finished")

	if waiter.waiting:
		yield(waiter, "finished")
