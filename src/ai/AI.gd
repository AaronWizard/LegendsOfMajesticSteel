class_name AI
extends Controller

onready var _random := RandomNumberGenerator.new()


func _ready() -> void:
	._ready()
	_random.randomize()


func connect_to_gui(_gui: BattleGUI) -> void:
	pass


func disconnect_from_gui(_gui: BattleGUI) -> void:
	pass


func determine_action() -> void:
	#print("Controller: Must implement determine_action()")
	print("AI.determine_action")
	get_battle_stats().finished = true
	emit_signal("determined_action", null)
