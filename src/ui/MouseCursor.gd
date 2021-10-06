extends Sprite


func _ready() -> void:
	visible = not OS.has_touchscreen_ui_hint()

	set_process(visible)
	if visible:
		position = get_global_mouse_position()
		_set_mouse_on_screen(position)


func _process(_delta: float) -> void:
	position = get_global_mouse_position()
	_set_mouse_on_screen(position)


func _set_mouse_on_screen(mouse_pos: Vector2) -> void:
	var rect := get_viewport().get_visible_rect()
	if rect.has_point(mouse_pos):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
