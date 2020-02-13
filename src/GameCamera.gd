class_name GameCamera
extends Camera2D

const TWEEN_SPEED = 200
const MAX_TIME = 0.5

onready var tween: Tween = get_node("Tween")


func follow_actor(actor: Actor) -> void:
	_start_move_camera(actor.remote_transform.global_position)
	yield(tween, "tween_all_completed")

	actor.remote_transform.remote_path = get_path()


func _start_move_camera(end: Vector2) -> void:
	var distance := position.distance_to(end)
	var time := distance / TWEEN_SPEED
	time = min(MAX_TIME, time)

	# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "position", position, end, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	tween.start()
