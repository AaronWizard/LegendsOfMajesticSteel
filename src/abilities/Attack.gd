class_name Attack
extends Ability

export var min_dist: int = 1
export var max_dist: int = 1

var _running_anims := 0


func get_range(source_cell: Vector2, _map: Map) -> Array:
	return TileGeometry.cells_in_range(source_cell, min_dist, max_dist)


func is_valid_target(target_cell: Vector2, _source_cell: Vector2, map: Map) \
		-> bool:
	var other_actor := map.get_actor_on_cell(target_cell)
	return other_actor and (other_actor.faction != get_actor().faction)


func get_valid_targets(source_cell: Vector2, map: Map) -> Array:
	var targets := []

	var ability_range := get_range(source_cell, map)
	for c in ability_range:
		var cell: Vector2 = c
		if is_valid_target(cell, source_cell, map):
			targets.append(cell)

	return targets


func start(target: Vector2, map: Map) -> void:
	var dir := target - get_actor().cell
	var anim: String = Actor.AnimationNames.ATTACK[dir]

	var target_actor := map.get_actor_on_cell(target)

	# warning-ignore:return_value_discarded
	get_actor().connect("animation_trigger", self, "_attacker_anim_trigger",
			[target_actor, dir], CONNECT_ONESHOT)
	_connect_anim_finished(get_actor())

	_running_anims = 1
	get_actor().play_anim(anim)


func _attacker_anim_trigger(trigger: String, target: Actor, dir: Vector2) \
		-> void:
	assert(trigger == Actor.AnimationNames.ATTACK_HIT_TRIGGER)
	var attack_power := Stats.get_attack_power(get_actor().stats, target.stats)
	target.battle_stats.modify_stamina(-attack_power)
	if target.battle_stats.is_alive:
		_connect_anim_finished(target)
		_running_anims += 1
		target.play_anim(Actor.AnimationNames.REACT[dir])


func _connect_anim_finished(actor: Actor) -> void:
	# warning-ignore:return_value_discarded
	actor.connect("animations_finished", self, "_anim_finished",
			[], CONNECT_ONESHOT)


func _anim_finished() -> void:
	_running_anims -= 1
	if _running_anims == 0:
		emit_signal("finished")
