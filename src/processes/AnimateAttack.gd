class_name AnimateAttack
extends Process

var actor: Actor
var direction: Vector2
var reduce_range: bool
var play_sound: bool
var on_hit_process: Process

var _attack_waiter := SignalWaiter.new()


func _init(new_on_hit: Process, new_actor: Actor, new_direction: Vector2,
		new_reduce_range := false, new_play_sound := true) \
		-> void:
	on_hit_process = new_on_hit
	actor = new_actor
	direction = new_direction
	reduce_range = new_reduce_range
	play_sound = new_play_sound

	_attack_waiter.wait_for_signal(actor, "attack_finished")
	_attack_waiter.wait_for_signal(on_hit_process, "finished")


func _run_self() -> void:
	actor.animate_attack(direction, reduce_range, play_sound)
	yield(actor, "attack_hit")
	on_hit_process.run()
	yield(_attack_waiter, "finished")
