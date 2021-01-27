class_name AITurn
extends TurnController

onready var _random := ExtRandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()


func pick_actor(actors: Array) -> Actor:
	var actor := _random.rand_array_element(actors) as Actor
	return actor
