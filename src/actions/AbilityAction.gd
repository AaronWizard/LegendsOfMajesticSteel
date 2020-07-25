class_name AbilityAction
extends Action

var ability: Ability
var target: Vector2


func _init(new_actor: Actor, new_map: Map, new_ability: Ability, \
		new_target: Vector2).(new_actor, new_map) -> void:
	ability = new_ability
	target = new_target


func start() -> void:
	ability.call_deferred("start", actor, map, target)
	yield(ability, "finished")

	actor.battle_stats.take_turn()

	emit_signal("finished")
