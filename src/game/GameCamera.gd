class_name GameCamera
extends Camera2D

var _current_actor: Actor = null
var _bounds := Rect2()


func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "_update_bounds")


func set_bounds(rect: Rect2) -> void:
	_bounds = rect
	_update_bounds()


func drag(relative: Vector2) -> void:
	stop_following_actor()

	var new_position := position - relative

	var resolution := get_viewport_rect().size
	var half_res := resolution / 2

	new_position.x = max(new_position.x, limit_left + half_res.x)
	new_position.x = min(new_position.x, limit_right - half_res.x)

	new_position.y = max(new_position.y, limit_top + half_res.y)
	new_position.y = min(new_position.y, limit_bottom - half_res.y)

	position = new_position


func follow_actor(actor: Actor) -> void:
	stop_following_actor()

	_set_smoothing(true)

	_current_actor = actor
	_current_actor.remote_transform.remote_path = get_path()


func move_to_position(new_position: Vector2) -> void:
	stop_following_actor()
	_set_smoothing(true)
	position = new_position


func stop_following_actor() -> void:
	if _current_actor:
		_current_actor.remote_transform.remote_path = NodePath()
		_current_actor = null

	_set_smoothing(false)
	position = get_camera_position()


func _set_smoothing(smoothing: bool) -> void:
	drag_margin_h_enabled = smoothing
	drag_margin_v_enabled = smoothing
	smoothing_enabled = smoothing


func _update_bounds() -> void:
	limit_left = int(_bounds.position.x)
	limit_top = int(_bounds.position.y)

	limit_right = int(_bounds.end.x)
	limit_bottom = int(_bounds.end.y)

	var viewport := get_viewport()
	if viewport:
		var view_size := viewport.get_visible_rect().size

		if view_size.x > _bounds.size.x:
			var margin := int((view_size.x - _bounds.size.x) / 2)
			limit_left -= margin
			limit_right += margin

		if view_size.y > _bounds.size.y:
			var margin := int((view_size.y - _bounds.size.y) / 2)
			limit_top -= margin
			limit_bottom += margin
