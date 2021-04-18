class_name DiamondAOE
extends SkillAOE

export var min_dist := 0
export var max_dist := 1


func get_aoe(target_cell: Vector2, _source_cell: Vector2, _source_actor: Actor,
		_map: Map) -> Array:
	return TileGeometry.cells_in_range(target_cell, min_dist, max_dist)
