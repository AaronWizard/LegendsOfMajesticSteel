class_name ActorSkillState
extends ActorAction

var _skill: Skill
var _target: Vector2


func start(data: Dictionary) -> void:
	_skill = data.skill as Skill
	assert(_skill)
	_target = data.target as Vector2
	assert(_target)

	_game.interface.camera.move_to_position(_target * Constants.TILE_SIZE)
	_game.interface.mouse.dragging_enabled = false
	_game.interface.map_highlights.moves_visible = false

	call_deferred("_run_skill")


func end() -> void:
	_skill = null


func _run_skill() -> void:
	yield(_skill.run(_game.current_actor, _game.map, _target), "completed")
	_finish(true)
