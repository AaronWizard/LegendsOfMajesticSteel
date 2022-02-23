class_name StatModifierDefinition
extends Resource

export(StatType.Type) var stat_type := StatType.Type.ATTACK

export var add_constant := 0
export var add_percent := 0.0

export(StatusEffectTiming.Type) var timing_type \
		:= StatusEffectTiming.Type.ROUNDS

export var rounds := 0
