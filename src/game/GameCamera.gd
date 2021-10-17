class_name GameCamera
extends Camera2D

var _MOVE_TIME := 0.25

onready var _tween := $Tween as Tween

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
	_stop_moving()

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
	_stop_moving()
	_set_smoothing(true, true)

	_current_actor = actor
	_current_actor.remote_transform.remote_path = get_path()


func move_to_position(new_position: Vector2, drag_margin := true) -> void:
	stop_following_actor()

	_stop_moving()

	# Don't use built-in screen smoothing. Camera somehow stops moving in
	# certain conditions and the extra control over the camera movement is
	# useful anyway.
	if not drag_margin or _need_move(new_position):
		# warning-ignore:return_value_discarded
		_tween.interpolate_property(self, "position", null, new_position,
				_MOVE_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
		# warning-ignore:return_value_discarded
		_tween.start()

		yield(_tween, "tween_all_completed")


func stop_following_actor() -> void:
	if _current_actor:
		_current_actor.remote_transform.remote_path = NodePath()
		_current_actor = null

	_set_smoothing(false, false)
	position = get_camera_position()


# For some reason toggling the built-in smoothing and dragging makes the
# camera unable to change its position. Specifically when you move a player
# actor, cancel its turn, and drag the mouse while the actor is moving back to
# its original position.
# Therefore dragging is being handled manually. See move_to_position.
func _need_move(new_position: Vector2) -> bool:
	var result := true

	var viewport := get_viewport()
	if viewport:
		var diff := new_position - position
		var screen_new_pos := get_global_transform_with_canvas().origin + diff

		var view_size := viewport.size
		var margin_left := view_size.x * drag_margin_left
		var margin_right := view_size.x * drag_margin_right
		var margin_top := view_size.y * drag_margin_top
		var margin_bottom := view_size.y * drag_margin_bottom

		var margin_start := Vector2(margin_left, margin_top)
		var margin_size := viewport.size - margin_start \
				- Vector2(margin_right, margin_bottom)

		var rect := Rect2(margin_start, margin_size)
		result = not rect.has_point(screen_new_pos)

	return result


func _stop_moving() -> void:
	# warning-ignore:return_value_discarded
	_tween.stop(self, "position")


func _set_smoothing(smoothing: bool, drag_margin: bool) -> void:
	drag_margin_h_enabled = drag_margin
	drag_margin_v_enabled = drag_margin
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

	position = position
