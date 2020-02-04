class_name Action
extends Node

signal finished

var actor: Actor
var map: Map


func start() -> void:
	print("Action must implement start()")
	emit_signal("finished")
