class_name MeleeAttackEffect
extends AbilityEffect

var _running_anims := 0


func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	assert(_running_anims == 0)

	var dir := target - source_actor.cell
	var anim: String = Actor.AnimationNames.ATTACK[dir]

	var target_actor := map.get_actor_on_cell(target)

	# warning-ignore:return_value_discarded

	source_actor.connect("animation_trigger", self, "_attacker_anim_trigger",
			[source_actor, target_actor, dir], CONNECT_ONESHOT)

	_connect_anim_finished(source_actor)
	source_actor.play_anim(anim)


func _attacker_anim_trigger(trigger: String, source: Actor, target: Actor, \
		dir: Vector2) -> void:
	assert(trigger == Actor.AnimationNames.ATTACK_HIT_TRIGGER)

	var attack_power := source.stats.attack
	target.battle_stats.modify_stamina(-attack_power)

	if target.battle_stats.is_alive:
		_connect_staimina_finished(target)

		_connect_anim_finished(target)
		target.play_anim(Actor.AnimationNames.REACT[dir])
	else:
		_connect_died(target)
		target.play_death_anim(dir)


func _connect_anim_finished(actor: Actor) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect("animation_finished", self, "_anim_finished",
			[], CONNECT_ONESHOT)


func _connect_staimina_finished(actor: Actor) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect("stamina_animation_finished", self,
			"_other_anim_finished", [], CONNECT_ONESHOT)


func _connect_died(actor: Actor) -> void:
	_running_anims += 1
	# warning-ignore:return_value_discarded
	actor.connect("died", self,
			"_other_anim_finished", [], CONNECT_ONESHOT)


func _anim_finished(_anim_name: String) -> void:
	_finish_anim()


func _other_anim_finished() -> void:
	_finish_anim()


func _finish_anim() -> void:
	_running_anims -= 1
	if _running_anims == 0:
		emit_signal("finished")
