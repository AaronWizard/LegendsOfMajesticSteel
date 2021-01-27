class_name ActorStatusPanel
extends PanelContainer

signal portrait_pressed

var _actor: Actor

onready var _portrait := $HBoxContainer/PortraitButton as Button
onready var _name := $HBoxContainer/VBoxContainer/Name as Label

onready var _stats := $HBoxContainer/VBoxContainer/Stats as Container

onready var _attack := _stats.get_node("Attack/Attack") as Label

onready var _defence_stats := _stats.get_node("Defence") \
		as Container

onready var _stamina_bar := _defence_stats.get_node(
		"StaminaBackground/CenterContainer/StaminaBar") as Range
onready var _current_stamina := _defence_stats.get_node("CurrentStamina") \
		as Label

onready var _conditions := $HBoxContainer/VBoxContainer/Conditions as Container


func set_actor(actor: Actor) -> void:
	clear()
	_portrait.icon = actor.portrait
	_portrait.disabled = false
	_name.text = actor.character_name

	_attack.text = str(actor.stats.attack)

	_stamina_bar.max_value = actor.stats.max_stamina
	_stamina_bar.value = actor.stats.stamina

	_current_stamina.text = str(actor.stats.stamina)

	_set_conditions(actor)
	# warning-ignore:return_value_discarded
	actor.connect("conditions_changed", self, "_set_conditions", [actor])
	_actor = actor


func clear() -> void:
	_portrait.icon = null
	_portrait.disabled = true
	_name.text = ""
	_stamina_bar.value = 0
	_current_stamina.text = ""

	if _actor:
		_actor.disconnect("conditions_changed", self, "_set_conditions")
		_actor = null


func _set_conditions(actor: Actor) -> void:
	for c in _conditions.get_children():
		var condition_icon := c as Node
		condition_icon.queue_free()

	for c in actor.conditions:
		var condition := c as Condition
		var icon := TextureRect.new()
		icon.texture = condition.effect.icon
		_conditions.add_child(icon)


func _on_PortraitButton_pressed() -> void:
	emit_signal("portrait_pressed")
