class_name MapEffectProcess
extends Process

var effect: Node2D
var signal_name: String
var map: Map

func _init(new_effect: Node2D, new_signal_name: String, new_map: Map) -> void:
	effect = new_effect
	signal_name = new_signal_name
	map = new_map


func _run_self() -> void:
	map.add_effect(effect)
	yield(effect, signal_name)
