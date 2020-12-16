tool
class_name RadialContainer
extends Container


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_children()


func _arrange_children() -> void:
	if get_children().size() > 0:
		var angle_offset := (2 * PI) / get_children().size()
		var angle := 0.0 # Radians

		var max_child_size := _max_child_size() / 2
		var center := rect_size / 2
		var radius := min(center.x - max_child_size.x, center.y - max_child_size.y)

		for c in get_children():
			var circle_pos := Vector2(radius, 0).rotated(angle) + center
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
