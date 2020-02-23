class_name GameCamera
extends Camera2D


func set_bounds(rect: Rect2) -> void:
	self.limit_left = int(rect.position.x)
	self.limit_top = int(rect.position.y)

	self.limit_right = int(rect.end.x)
	self.limit_bottom = int(rect.end.y)


func drag(relative: Vector2) -> void:
	stop_following_actor()
	position -= relative


func follow_actor(actor: Actor) -> void:
	drag_margin_h_enabled = true
	drag_margin_v_enabled = true
	smoothing_enabled = true
	actor.remote_transform.remote_path = get_path()


func stop_following_actor() -> void:
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false
	smoothing_enabled = false
	position = get_camera_position()
