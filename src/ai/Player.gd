class_name Player
extends Controller

signal _input_processed(action)


func _ready() -> void:
	._ready()
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var target_cell := get_map().get_mouse_cell()

		if _can_walk_to_cell(target_cell):
			var path := []

			var c := Vector2(get_actor().cell)
			if c == target_cell:
				path.append(c)
			else:
				while c != target_cell:
					if c.x < target_cell.x:
						c.x += 1
					elif c.x > target_cell.x:
						c.x -= 1
					elif c.y < target_cell.y:
						c.y += 1
					elif c.y > target_cell.y:
						c.y -= 1
					path.append(Vector2(c))

			var action := MoveAction.new()
			action.actor = get_actor()
			action.map = get_map()
			action.path = path

			emit_signal("_input_processed", action)


func determine_action() -> void:
	set_process_unhandled_input(true)
	var action: Action = yield(self, '_input_processed')
	set_process_unhandled_input(false)
	emit_signal("determined_action", action)


func _can_walk_to_cell(cell: Vector2) -> bool:
	var result := (cell != get_actor().cell) \
			and (cell in get_battle_stats().walk_cells)

	return result
