class_name ArcAOE
extends SkillAOE


func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		_map: Map) -> Array:
	var rect := source_actor.get_cell_rect_at_cell(source_cell)

	var direction_type := TileGeometry.direction_from_rect_to_cell(
			target_cell, rect)

	var left_type := Directions.left_direction_type(direction_type)
	var right_type := Directions.right_direction_type(direction_type)

	var left_side := TileGeometry.get_rect_side_cells(rect, left_type, 1)
	var main_side := TileGeometry.get_rect_side_cells(rect, direction_type, 1)
	var right_side := TileGeometry.get_rect_side_cells(rect, right_type, 1)

	return left_side + main_side + right_side
