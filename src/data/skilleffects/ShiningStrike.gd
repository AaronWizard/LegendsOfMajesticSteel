class_name ShiningStrike
extends SkillEffect

export var effect_scene: PackedScene
export var condition_effect: Resource


func run(target_cell: Vector2, aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var on_hit := Process.new()
	on_hit.concurrent_children = true

	var dir_type := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.cell_rect)
	var direction := Directions.get_direction(dir_type)

	var effect := _create_spell_effect(target_cell, dir_type)
	var effect_process := MapEffectProcess.new(
			effect, "animation_finished", map)
	on_hit.children.append(effect_process)

	var other_actors := map.get_actors_on_cells(aoe)
	for a in other_actors:
		var other_actor := a as Actor
		if other_actor.faction != source_actor.faction:
			var hit := TakeDamageProcess.new(
					other_actor, map, source_actor.stats.attack,
					other_actor.center_cell - source_actor.center_cell)
			var penalty := ApplyConditionProcess.new(
					other_actor, condition_effect as ConditionEffect)

			on_hit.children.append(hit)
			on_hit.children.append(penalty)

	var attack := AttackProcess.new(source_actor, direction, true, on_hit)

	attack.run()
	yield(attack, "finished")


func _create_spell_effect(cell: Vector2, direction: int) -> SpellAnimation:
	var result := effect_scene.instance() as SpellAnimation
	result.cell = cell
	result.direction = direction
	return result
