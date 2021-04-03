class_name PushAttackActorEffect, "res://assets/editor/pushattack_effect.png"
extends SkillEffect


func get_aoe(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Array:
	return []


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return {}


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map):
	pass
