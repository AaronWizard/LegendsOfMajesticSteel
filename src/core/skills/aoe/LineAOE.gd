class_name LineAOE
extends SkillAOE

func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		_map: Map) -> Array:
	return TileGeometry.get_thick_line(
			source_cell, target_cell, source_actor.rect_size)
