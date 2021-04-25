class_name AIPickActor

const _DIST_RANDOM_WEIGHT := 0.25

var _random := RandomNumberGenerator.new()


func _get_faction() -> int:
	return Actor.Faction.ENEMY


func pick_actor(actors: Array, map: Map) -> Actor:
	_random.randomize()

	var enemies := _enemy_actors(map)
	var actor := _get_sorted_actor(actors, enemies)

	return actor


func _enemy_actors(map: Map) -> Array:
	var result := []
	var actors := map.get_actors()
	for a in actors:
		var actor := a as Actor
		if actor.faction == Actor.Faction.PLAYER:
			result.append(actor)
	return result


func _get_sorted_actor(actors: Array, enemies: Array) -> Actor:
	var sort_array := []

	var max_dist_sqr = -1
	for a in actors:
		var actor := a as Actor
		var tuple := { actor = actor, distance_sqr = -1 }

		for e in enemies:
			var enemy := e as Actor
			var distance_sqr := \
					enemy.origin_cell.distance_squared_to(actor.origin_cell)
			if max_dist_sqr == -1 or (distance_sqr > max_dist_sqr):
				max_dist_sqr = distance_sqr
			if (tuple.distance_sqr == -1) \
					or (distance_sqr < tuple.distance_sqr):
				tuple.distance_sqr = distance_sqr

		sort_array.append(tuple)

	for t in sort_array:
		var rand_dist := _random.randf_range(
			-(max_dist_sqr * _DIST_RANDOM_WEIGHT),
			(max_dist_sqr * _DIST_RANDOM_WEIGHT)
		)
		var tuple := t as Dictionary
		tuple.distance_sqr += rand_dist

	sort_array.sort_custom(self, "_sort")

	var first_tuple := sort_array.front() as Dictionary
	var result := first_tuple.actor as Actor

	return result


static func _sort(tuple_a: Dictionary, tuple_b: Dictionary) -> bool:
	return tuple_a.distance_sqr < tuple_b.distance_sqr
