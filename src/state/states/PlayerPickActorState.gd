class_name PlayerPickActorState
extends State

var _interface: BattleInterface
var _player_turn: PlayerTurn
var _actors: Array

var _chosen_actor: Actor


func _init(interface: BattleInterface, player_turn: PlayerTurn, actors: Array) \
		-> void:
	_interface = interface
	_player_turn = player_turn
	_actors = actors


func start() -> void:
	_set_actor_cursors(true)
	_position_player_turn_camera()
	_interface.mouse.dragging_enabled = true

	# warning-ignore:return_value_discarded
	_interface.mouse.connect("click", self, "_mouse_click")


func end() -> void:
	_interface.mouse.disconnect("click", self, "_mouse_click")
	_set_actor_cursors(false)
	_player_turn.use_actor(_chosen_actor)


func _set_actor_cursors(cursor_visible: bool) -> void:
	for a in _actors:
		var actor := a as Actor
		actor.target_visible = cursor_visible


func _position_player_turn_camera() -> void:
	var average_pos := Vector2.ZERO
	for a in _actors:
		var actor := a as Actor
		average_pos += actor.position
	average_pos /= float(_actors.size())

	_interface.camera.move_to_position(average_pos)


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _interface.current_map.get_mouse_cell()
	for a in _actors:
		var actor := a as Actor
		if actor.on_cell(target_cell):
			_pick_player_actor(actor)
			break


func _pick_player_actor(actor: Actor) -> void:
	_chosen_actor = actor
	emit_signal("pop_state")
