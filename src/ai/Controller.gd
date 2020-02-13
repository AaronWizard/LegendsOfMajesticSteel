class_name Controller
extends TurnTaker

var actor: Actor setget , get_actor
var map: Map setget , get_map


func _ready() -> void:
	assert(get_actor())
	get_actor().controller = self


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
