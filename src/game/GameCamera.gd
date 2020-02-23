class_name GameCamera
extends Camera2D

export var offset_reset_speed := 32

onready var _tween: Tween = $Tween


func set_bounds(rect: Rect2) -> void:
	self.limit_left = int(rect.position.x)
	self.limit_top = int(rect.position.y)

	self.limit_right = int(rect.end.x)
	self.limit_bottom = int(rect.end.y)


func drag(relative: Vector2) -> void:
	offset -= relative


func reset_offset() -> void:
	if offset != Vector2.ZERO:
		var time := offset.length() / (offset_reset_speed * 8)
		# warning-ignore:return_value_discarded
		_tween.interpolate_property(self, "offset", offset, Vector2.ZERO,
				time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		# warning-ignore:return_value_discarded
		_tween.start()

func follow_actor(actor: Actor) -> void:
	actor.remote_transform.remote_path = get_path()
