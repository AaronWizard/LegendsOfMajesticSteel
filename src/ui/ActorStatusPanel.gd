class_name ActorStatusPanel
extends PanelContainer

signal portrait_pressed

onready var _portrait := $HBoxContainer/PortraitButton as Button
onready var _name := $HBoxContainer/VBoxContainer/Name as Label

onready var _stamina_bar := $HBoxContainer/VBoxContainer/VBoxContainer/ \
		StaminaBackground/CenterContainer/StaminaBar as Range
onready var _current_stamina := $HBoxContainer/VBoxContainer/VBoxContainer/ \
		HBoxContainer/CurrentStamina as Label
onready var _max_stamina := $HBoxContainer/VBoxContainer/VBoxContainer/ \
		HBoxContainer/MaxStamina as Label


func set_actor(actor: Actor) -> void:
	clear()
	_portrait.icon = actor.portrait
	_portrait.disabled = false
	_name.text = actor.character_name

	_stamina_bar.max_value = actor.stats.max_stamina
	_stamina_bar.value = actor.battle_stats.stamina

	_max_stamina.text = str(actor.stats.max_stamina)
	_current_stamina.text = str(actor.battle_stats.stamina)


func clear() -> void:
	_portrait.icon = null
	_portrait.disabled = true
	_name.text = ""
	_stamina_bar.value = 0
	_current_stamina.text = ""
	_max_stamina.text = ""


func _on_PortraitButton_pressed() -> void:
	emit_signal("portrait_pressed")
