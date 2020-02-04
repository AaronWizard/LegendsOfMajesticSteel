class_name Action
extends Node

signal action_finished


func run(actor: Actor, map: Map) -> void:
	emit_signal("action_finished")
