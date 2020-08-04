class_name AITurn
extends TurnController

onready var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()


func pick_actor(actors: Array, _control: BattleInterface) -> void:
	var index := _random.randi_range(0, actors.size() - 1)
	var actor := actors[index] as Actor
	emit_signal("actor_picked", actor)
