class_name StatModifier

signal finished

var stat_type: int

var add_constant: int
var add_percent: float

var timing_type: int
var rounds: int


func _init(definition: StatModifierDefinition) -> void:
	stat_type = definition.stat_type

	add_constant = definition.add_constant
	add_percent = definition.add_percent

	timing_type = definition.timing_type
	rounds = definition.rounds


func start_round() -> void:
	if timing_type == StatusEffectTiming.Type.ROUNDS:
		rounds -= 1
		if rounds <= 0:
			emit_signal("finished")
