class_name DiamondRange
extends TargetRange


export var min_dist := 1
export var max_dist := 1
export var include_diagonals := true


func get_full_range(source_cell: Vector2, source_actor: Actor) -> Array:
	return TileGeometry.cells_in_range_rect(
			source_cell, source_actor.size,
			min_dist, max_dist, include_diagonals)
