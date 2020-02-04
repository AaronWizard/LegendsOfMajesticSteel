class_name Player
extends Controller


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		get_actor().cell = get_map().get_mouse_cell()
