class_name Controller
extends Node

signal determined_action(action)

var actor: Actor setget , get_actor
var map: Map setget , get_map


func get_actor() -> Actor:
	var result = null
	var parent = get_parent()
	if parent is Actor:
		result = parent as Actor
	return result


func get_map() -> Map:
	var result = null
	var a = get_actor()
	if a:
		result = a.owner as Map

	return result


func _ready() -> void:
	assert(get_actor())
	assert(get_map())
	get_actor().controller = self


func determine_action() -> void:
	print("Controller: Must implement determine_action()")
	emit_signal("determined_action", null)