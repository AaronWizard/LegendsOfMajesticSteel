class_name PushActorProcess
extends Process

const _SPEED := 1.5

var actor: Actor
var map: Map
var attack: int
var direction: int
var distance: int


func _init(new_actor: Actor, new_map: Map, new_attack: int,
		new_direction: int, new_distance: int) -> void:
	actor = new_actor
	map = new_map
	attack = new_attack
	direction = new_direction
	distance = new_distance


func _run_self() -> void:
	var dir := Directions.get_vector(direction)

	var final_attack := attack
	var final_distance := 0
	var final_cell := actor.origin_cell

	for _i in range(1, distance + 1):
		if not map.actor_can_enter_cell(actor, final_cell + dir):
#			actor.origin_cell = next_cell
#			actor.cell_offset = -dir
			final_attack *= 2
			break
		else:
			final_cell += dir
			final_distance += 1

	actor.stats.take_damage(final_attack)

	if final_distance > 0:
		actor.cell_offset = actor.origin_cell - final_cell
		actor.origin_cell = final_cell

		yield(
			actor.animate_offset(
					Vector2.ZERO, _SPEED * distance, Tween.TRANS_ELASTIC, Tween.EASE_OUT),
			"completed"
		)

	if not actor.is_alive:
		actor.animate_death(Vector2.ZERO)
		yield(actor, "died")
