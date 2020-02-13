class_name GameCamera
extends Camera2D

onready var tween: Tween = get_node("Tween")

const TWEEN_SPEED = 200
const MAX_TIME = 0.5

func follow_actor(actor: Actor) -> void:
	start_move_camera(actor.remote_transform.global_position)
	yield(tween, "tween_all_completed")

	actor.remote_transform.remote_path = get_path()

func start_move_camera(end: Vector2) -> void:
	var distance := position.distance_to(end)
	var time := distance / TWEEN_SPEED
	time = min(MAX_TIME, time)

	# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "position", position, end, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	tween.start()
