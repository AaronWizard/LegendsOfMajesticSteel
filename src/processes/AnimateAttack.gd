class_name AnimateAttack
extends Process

var actor: Actor
var direction: Vector2
var ranged: bool
var on_hit_process: Process

var _attack_waiter := SignalWaiter.new()


func _init(new_actor: Actor, new_direction: Vector2, new_ranged: bool,
		new_on_hit: Process) -> void:
	actor = new_actor
	direction = new_direction
	ranged = new_ranged
	on_hit_process = new_on_hit

	_attack_waiter.wait_for_signal(actor, "attack_finished")
	_attack_waiter.wait_for_signal(on_hit_process, "finished")


func _run_self() -> void:
	actor.animate_attack(direction, ranged)
	yield(actor, "attack_hit")
	on_hit_process.run()
	yield(_attack_waiter, "finished")
