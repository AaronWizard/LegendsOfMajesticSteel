class_name AITurn
extends TurnController

onready var _random := ExtRandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()


func pick_actor(actors: Array) -> void:
	var actor := _random.rand_array_element(actors) as Actor
	emit_signal("actor_picked", actor)
