class_name Player
extends Controller


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var target_cell = get_map().get_mouse_cell()

		set_process_unhandled_input(false)

		while get_actor().cell != target_cell:
			var next_cell := get_actor().cell

			if next_cell.x < target_cell.x:
				next_cell.x += 1
			elif next_cell.x > target_cell.x:
				next_cell.x -= 1
			elif next_cell.y < target_cell.y:
				next_cell.y += 1
			elif next_cell.y > target_cell.y:
				next_cell.y -= 1

			get_actor().move_step(next_cell)
			yield(get_actor(), "animations_finished")

		set_process_unhandled_input(true)
