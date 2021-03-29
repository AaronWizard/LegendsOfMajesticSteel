class_name PlayerPickActorState
extends PlayerState

var _player_turn: PlayerTurn
var _actors: Array

onready var _pick_sound := $PickSound as AudioStreamPlayer


func start(data: Dictionary) -> void:
	.start(data)

	_player_turn = data.player_turn as PlayerTurn
	assert(_player_turn)
	_actors = data.actors as Array
	assert(_actors)
	assert(_actors[0] is Actor)

	_set_actor_cursors(true)
	_position_player_turn_camera()


func end() -> void:
	.end()
	_set_actor_cursors(false)
	_player_turn = null
	_actors.clear()


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
			_pick_sound.play()
			_player_turn.use_actor(actor)
			break
