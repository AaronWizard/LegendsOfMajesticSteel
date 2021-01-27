class_name Action

var actor: Actor
var map: Map


func _init(new_actor: Actor, new_map: Map) -> void:
	actor = new_actor
	map = new_map


func show_map_highlights() -> bool:
	return false


func run() -> void:
	print("Action must implement start()")
