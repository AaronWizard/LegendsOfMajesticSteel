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


func get_target_info(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor) -> TargetingData.TargetInfo:
	var result := TargetingData.TargetInfo.new()
	for e in get_children():
		var effect := e as SkillEffect
		var e_info := effect.get_target_info(
				target_cell, source_cell, source_actor)
		result.add(e_info)
	return result


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor) -> void:
	var waiter := SignalWaiter.new()

	for c in get_children():
		var child := c as SkillEffect
		child.run(target_cell, source_cell, source_actor)
		if group_type == GroupType.SEQUENCE:
			yield(child, "finished")
		else:
			assert(child.running)
			waiter.wait_for_signal(child, "finished")

	if waiter.waiting:
		yield(waiter, "finished")
