class_name SkillEffectsUtil


static func predict_standard_damage(aoe: Array, source_actor: Actor, map: Map) \
		-> Dictionary:
	var result := {}

	for c in aoe:
		var cell := c as Vector2
		var actor := map.get_actor_on_cell(cell)
		if actor and (actor.faction != source_actor.faction) \
				and not result.has(actor):
			var damage := actor.stats.damage_from_attack( \
					source_actor.stats.attack)
			result[actor] = -damage

	return result
