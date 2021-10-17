class_name ActorSkillState
extends ActorActionState

var _skill: Skill
var _target: Vector2


func start(data: Dictionary) -> void:
	_skill = data.skill as Skill
	assert(_skill)
	_target = data.target as Vector2
	assert(_target)

	var target_pos \
			:= (_target * Constants.TILE_SIZE) + Constants.TILE_HALF_SIZE_V
	_game.interface.camera.move_to_position(target_pos)

	.start(data)


func end() -> void:
	_skill = null


func _show_move_range() -> bool:
	return false


func _run() -> void:
	yield(_skill.run(_game.current_actor, _game.map, _target), "completed")
