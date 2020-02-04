class_name MoveAction
extends Action

var path: Array


func start() -> void:
	for c in path:
		var cell := c as Vector2
		actor.move_step(cell)
		yield(actor, "animations_finished")

	emit_signal("finished")
