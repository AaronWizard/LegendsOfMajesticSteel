class_name ActorLineAOE
extends SkillAOE

export var include_start := true
export var include_end := true

func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		_map: Map) -> Array:
	var result := TileGeometry.get_thick_line(
			source_cell, target_cell, source_actor.rect_size)
	if not include_start:
		_remove_cells_from_result(result, source_actor.covered_cells)
	if not include_end:
		_remove_cells_from_result(
				result, source_actor.get_covered_cells_at_cell(target_cell))
	return result


func _remove_cells_from_result(result: Array, cells: Array) -> void:
	for c in cells:
		var cell := c as Vector2
		result.erase(cell)
		assert(result.find(cell) == -1)
