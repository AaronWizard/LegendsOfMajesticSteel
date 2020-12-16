tool
class_name RadialContainer
extends Container


export(float, 0, 359) var base_rotation := 0.0 setget set_base_rotation # Degrees


func set_base_rotation(new_value: float) -> void:
	base_rotation = new_value
	_arrange_children()


func _arrange_children() -> void:
	if get_children().size() > 0:
		var angle_offset := (2 * PI) / get_children().size()
		var angle := deg2rad(base_rotation) # Radians

		var max_child_half_size := _max_child_size() / 2
		var center := rect_size / 2
		var circle_size := center - max_child_half_size

		for c in get_children():
			var circle_pos := (Vector2(1, 0).rotated(angle) * circle_size) \
					+ center
			angle += angle_offset

			var control := c as Control
			control.rect_position = circle_pos - (control.rect_size / 2)


func _max_child_size() -> Vector2:
	var result := Vector2.ZERO
	for c in get_children():
		var control := c as Control
		result.x = max(result.x, control.rect_size.x)
		result.y = max(result.y, control.rect_size.y)
	return result


func _on_RadialContainer_sort_children() -> void:
	_arrange_children()
