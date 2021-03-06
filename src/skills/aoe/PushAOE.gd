class_name PushAOE
extends SkillAOE

export var distance := 1


func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var target_actor := map.get_actor_on_cell(target_cell)
	var direction := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.get_cell_rect_at_cell(source_cell))
	var dir_vec := Directions.get_vector(direction)

	var real_distance := PushActor.get_real_distance(target_actor, map,
		direction, distance)
	var blocking_actors := PushActor.get_blocking_actors(target_actor, map,
			direction, real_distance)
	if blocking_actors.size() > 0:
		real_distance += 1

	var end_cell := (dir_vec * real_distance) + target_actor.origin_cell
	return TileGeometry.get_thick_line(
			target_actor.origin_cell, end_cell, target_actor.rect_size)
