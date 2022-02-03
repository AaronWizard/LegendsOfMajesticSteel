class_name MapAnimationEffect, "res://assets/editor/mapanim_effect.png"
extends SkillEffect

export var map_anim_scene: PackedScene
export var rotated := false


func _run_self(target_cell: Vector2, _source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	var map_anim := map_anim_scene.instance() as MapAnimation
	map.add_effect(map_anim)

	map_anim.origin_cell = target_cell
	if rotated:
		map_anim.anim_rotation = target_cell.angle_to_point(
				source_actor.origin_cell)

	map_anim.start_animation()
	yield(map_anim, "finished")
