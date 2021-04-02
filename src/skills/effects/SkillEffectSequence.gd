class_name SkillEffectSequence
extends SkillEffectGroup


func _run_self(target_cell: Vector2, source_actor: Actor, map: Map) -> void:
	for c in get_children():
		var child := c as SkillEffect
		child.run(target_cell, source_actor, map)
		yield(child, "finished")
