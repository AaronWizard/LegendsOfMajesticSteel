class_name ActorsInAttackRangeAOE
extends SkillAOE

enum Faction { ANY, ALLIES, ENEMIES }

export(Faction) var faction := 1

func get_aoe(target_cell: Vector2, _source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := []

	for a in map.get_actors():
		var actor := a as Actor

		var same_faction := actor.faction == source_actor.faction

		if ((faction == Faction.ANY) \
				or ((faction == Faction.ALLIES) and same_faction) \
				or ((faction == Faction.ENEMIES) and not same_faction)) \
				and _attack_in_range(actor, map, target_cell):
			result.append_array(actor.covered_cells)

	return result


func _attack_in_range(actor: Actor, map: Map, target_cell: Vector2) -> bool:
	var attack_skill := actor.attack_skill as Skill
	var target_data := attack_skill.get_targeting_data(
			actor.origin_cell, actor, map)

	return target_data.valid_targets.has(target_cell)