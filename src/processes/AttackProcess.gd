class_name AttackProcess
extends Process

var target_actor: Actor
var map: Map
var attack: int
var attack_direction: Vector2

var _waiter := SignalWaiter.new()


func _init(new_actor: Actor, new_map: Map, new_attack: int,
		new_attack_direction: Vector2) -> void:
	target_actor = new_actor
	map = new_map
	attack = new_attack
	attack_direction = new_attack_direction


func run() -> void:
	target_actor.stats.take_damage(attack)

	if target_actor.is_alive:
		_waiter.wait_for_signal(target_actor, "stamina_animation_finished")
		_waiter.wait_for_signal(target_actor, "hit_reaction_finished")
		target_actor.animate_hit(attack_direction)
	else:
		target_actor.animate_death(attack_direction)
		yield(target_actor, "died")

	if _waiter.waiting:
		yield(_waiter, "finished")

	emit_signal("finished")
