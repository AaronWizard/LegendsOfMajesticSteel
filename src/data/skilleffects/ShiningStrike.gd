class_name ShiningStrike
extends SkillEffect


export var effect_scene: PackedScene

var _waiter := SignalWaiter.new()


func run(target_cell: Vector2, aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var dir_type := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.cell_rect)
	var direction := Directions.get_direction(dir_type)

	var other_actors := map.get_actors_on_cells(aoe)
	var attacks := []
	for a in other_actors:
		var other_actor := a as Actor
		if other_actor.faction != source_actor.faction:
			var attack := AttackProcess.new(
					other_actor, map, source_actor.stats.attack,
					other_actor.center_cell - source_actor.center_cell)
			#_waiter.wait_for_signal(attack, "completed")

	var effect := _create_spell_effect(target_cell, dir_type)

	_waiter.wait_for_signal(source_actor, "attack_finished")
	source_actor.animate_attack(direction, true)
	yield(source_actor, "attack_hit")

	map.add_effect(effect)
	yield(effect, "animation_finished")

	if _waiter.waiting:
		yield(_waiter, "finished")


func _create_spell_effect(cell: Vector2, direction: int) -> SpellAnimation:
	var result := effect_scene.instance() as SpellAnimation
	result.cell = cell
	result.direction = direction
	return result
