class_name TurnManager

var actors := []
var running := false

var _current_index := 0

func start() -> void:
	running = true
	_current_index = 0

	while running:
		var actor := actors[_current_index] as Actor
		var controller := actor.controller
		if controller:
			controller.determine_action()
			var action: Action = yield(controller, "determined_action")
			if action:
				action.start()
				yield(action, "finished")

		_current_index = (_current_index + 1) % actors.size()
