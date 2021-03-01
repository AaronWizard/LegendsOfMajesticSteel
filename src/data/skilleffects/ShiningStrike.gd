class_name ShiningStrike
extends SkillEffect

export var effect_scene: PackedScene
export var condition_effect: Resource


func predict_damage(_target_cell: Vector2, aoe: Array, _source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return SkillEffectsUtil.predict_standard_damage(aoe, source_actor, map)


func run(target_cell: Vector2, aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var on_hit := Process.new()
	on_hit.concurrent_children = true

	var dir_type := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.cell_rect)
	var direction := Directions.get_vector(dir_type)

	var effect := _create_spell_effect(target_cell, dir_type)
	var effect_process := AddMapEffect.new(
			effect, "animation_finished", map)
	on_hit.children.append(effect_process)

	var other_actors := map.get_actors_on_cells(aoe)
	for a in other_actors:
		var other_actor := a as Actor
		if other_actor.faction != source_actor.faction:
			var hit := DamageActor.new(
					other_actor, map, source_actor.stats.attack,
					other_actor.center_cell - source_actor.center_cell)
			var penalty := ApplyCondition.new(
					other_actor, condition_effect as ConditionEffect)

			on_hit.children.append(hit)
			on_hit.children.append(penalty)

	var attack := AnimateAttack.new(source_actor, direction, true, on_hit)

	attack.run()
	yield(attack, "finished")


func _create_spell_effect(cell: Vector2, direction: int) -> SpellAnimation:
	var result := effect_scene.instance() as SpellAnimation
	result.cell = cell
	result.direction = direction
	return result
