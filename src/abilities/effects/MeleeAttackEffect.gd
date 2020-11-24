class_name MeleeAttackEffect
extends AbilityEffect

var _running_anims := 0


func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	assert(_running_anims == 0)

	var dir := target - source_actor.cell
	var target_actor := map.get_actor_on_cell(target)

	_connect_actor_signal(source_actor, "attack_finished")
	source_actor.animate_attack(dir)
	yield(source_actor, "attack_hit")

	target_actor.battle_stats.modify_stamina(-source_actor.stats.attack)

	if target_actor.battle_stats.is_alive:
		_connect_actor_signal(target_actor, "stamina_animation_finished")
		_connect_actor_signal(target_actor, "hit_reaction_finished")
		target_actor.animate_hit(dir)
	else:
		_connect_actor_signal(target_actor, "died")
		target_actor.animate_death(dir)


func _connect_actor_signal(actor: Actor, signal_name: String) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect(signal_name, self, "_anim_finished", [], CONNECT_ONESHOT)


func _anim_finished() -> void:
	_running_anims -= 1
	if _running_anims == 0:
		emit_signal("finished")
