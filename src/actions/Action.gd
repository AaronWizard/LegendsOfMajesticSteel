class_name Action
extends Node

signal finished

var actor: Actor
var map: Map


func _init(new_actor: Actor, new_map: Map) -> void:
	actor = new_actor
	map = new_map


func start() -> void:
	print("Action must implement start()")
	emit_signal("finished")
