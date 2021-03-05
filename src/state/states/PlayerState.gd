class_name PlayerState
extends State

export var interface_path: NodePath

onready var _interface := get_node(interface_path) as BattleInterface


func start(_data: Dictionary) -> void:
	_interface.mouse.dragging_enabled = true
	# warning-ignore:return_value_discarded
	_interface.mouse.connect("click", self, "_mouse_click")


func end() -> void:
	_interface.mouse.dragging_enabled = false
	_interface.mouse.disconnect("click", self, "_mouse_click")


func _mouse_click(_position: Vector2) -> void:
	pass
