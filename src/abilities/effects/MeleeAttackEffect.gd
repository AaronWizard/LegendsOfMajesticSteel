class_name MeleeAttackEffect
extends AbilityEffect

var _running_anims := 0


func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	assert(_running_anims == 0)

	var dir := target - source_actor.cell
	var target_actor := map.get_actor_on_cell(target)

	# warning-ignore:return_value_discarded
	source_actor.connect("attack_hit", self, "_attack_hit",
			[source_actor, target_actor, dir], CONNECT_ONESHOT)

	_running_anims = 1
	# warning-ignore:return_value_discarded
	source_actor.connect("attack_finished", self, "_anim_finished", [],
			CONNECT_ONESHOT)

	source_actor.animate_attack(dir)


func _attack_hit(source: Actor, target: Actor, dir: Vector2) -> void:
	target.battle_stats.modify_stamina(-source.stats.attack)

	if target.battle_stats.is_alive:
		_connect_staimina_finished(target)
		_connect_react_finished(target)
		target.animate_hit(dir)
	else:
		_connect_died(target)
		target.animate_death(dir)


func _connect_staimina_finished(actor: Actor) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect("stamina_animation_finished", self, "_anim_finished", [],
			CONNECT_ONESHOT)


func _connect_react_finished(actor: Actor) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect("hit_reaction_finished", self, "_anim_finished", [],
			CONNECT_ONESHOT)


func _connect_died(actor: Actor) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect("died", self, "_anim_finished", [], CONNECT_ONESHOT)


func _anim_finished() -> void:
	_finish_anim()


func _finish_anim() -> void:
	_running_anims -= 1
	if _running_anims == 0:
		emit_signal("finished")
