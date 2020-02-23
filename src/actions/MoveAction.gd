class_name MoveAction
extends Action

var path: Array


func _init(new_actor: Actor, new_map: Map, new_path: Array) \
		.(new_actor, new_map) -> void:
	path = new_path


func start() -> void:
	for c in path:
		var cell: Vector2 = c
		actor.move_step(cell)
		yield(actor, "animations_finished")

	emit_signal("finished")
