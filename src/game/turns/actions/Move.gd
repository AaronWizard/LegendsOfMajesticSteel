class_name Move
extends Action

var path: Array

var _mouse: MouseControl = null


func _init(new_actor: Actor, new_map: Map, new_path: Array) \
		.(new_actor, new_map) -> void:
	path = new_path


func show_map_highlights() -> bool:
	return true


func run() -> void:
	while path.size() > 0:
		var cell := path.pop_front() as Vector2
		actor.move_step(cell)
		yield(actor, "move_finished")

	if _mouse:
		_mouse.disconnect("click", self, "_click_to_cancel")
		_mouse = null


func allow_cancel(mouse: MouseControl) -> void:
	_mouse = mouse
	# warning-ignore:return_value_discarded
	mouse.connect("click", self, "_click_to_cancel")


func _click_to_cancel(_position) -> void:
	if map.actor_can_enter_cell(actor, actor.origin_cell):
		path.clear()
