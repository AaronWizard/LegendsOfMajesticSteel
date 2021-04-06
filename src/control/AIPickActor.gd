class_name AIPickActor

var _random := ExtRandomNumberGenerator.new()


func _get_faction() -> int:
	return Actor.Faction.ENEMY


func pick_actor(actors: Array, _map: Map) -> Actor:
	_random.randomize()
	var actor := _random.rand_array_element(actors) as Actor
	return actor
