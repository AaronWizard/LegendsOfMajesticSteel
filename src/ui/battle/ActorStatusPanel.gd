class_name ActorStatusPanel
extends Control

signal portrait_pressed

onready var _portrait_button := $PortraitButton as Button
onready var _portrait := _portrait_button.get_node("Portrait") as TextureRect

onready var _name := $PanelContainer/MarginContainer/VBoxContainer/Name as Label

onready var _attack := $PanelContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer2/Attack as Label

onready var _stamina_bar := $PanelContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer/StaminaBackground/StaminaBar as Range
onready var _current_stamina := $PanelContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer/CurrentStamina as Label

onready var _energy_icon := $PanelContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer2/EnergyIcon as Control
onready var _current_energy := $PanelContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer2/CurrentEnergy as Label


func set_actor(actor: Actor, portrait_clickable: bool) -> void:
	clear()
	_portrait_button.disabled = not portrait_clickable
	_portrait.texture = actor.portrait

	_name.text = actor.character_name

	_attack.text = str(actor.stats.attack)

	_stamina_bar.max_value = actor.stats.max_stamina
	_stamina_bar.value = actor.stats.stamina

	_set_energy_visible(actor.stats.max_energy > 0)

	_current_stamina.text = str(actor.stats.stamina)
	_current_energy.text = str(actor.stats.energy)


func clear() -> void:
	_portrait_button.disabled = true
	_portrait.texture = null
	_name.text = ""

	_stamina_bar.value = 0

	_current_stamina.text = ""
	_current_energy.text = ""


func _set_energy_visible(visible: bool) -> void:
	_energy_icon.visible = visible
	_current_energy.visible = visible


func _on_PortraitButton_pressed() -> void:
	emit_signal("portrait_pressed")
