class_name ApplyConditionProcess
extends Process


var actor: Actor
var condition_effect: ConditionEffect


func _init(new_actor: Actor, new_condition: ConditionEffect) -> void:
	actor = new_actor
	condition_effect = new_condition


func _run_self() -> void:
	actor.add_condition(Condition.new(condition_effect))
