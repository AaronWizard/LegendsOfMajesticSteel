class_name ActorStatusPanel
extends PanelContainer

signal portrait_pressed

onready var _portrait_button := $VBoxContainer/HBoxContainer/PortraitButton \
		as Button
onready var _portrait := $VBoxContainer/HBoxContainer/PortraitButton/Portrait \
		as TextureRect

onready var _name := $VBoxContainer/NameMargin/Name as Label

onready var _stats := $VBoxContainer/HBoxContainer/StatsMargin/Stats \
		as Container

onready var _attack := _stats.get_node("Attack") as Label

onready var _stamina_bar := _stats.get_node("StaminaBackground/StaminaBar") \
		as Range
onready var _current_stamina := _stats.get_node("CurrentStamina") as Label

onready var _energy_bar := _stats.get_node("EnergyBackground/EnergyBar") \
		as Range
onready var _current_energy := _stats.get_node("CurrentEnergy") as Label

onready var _energy_icon := _stats.get_node("EnergyIcon") as Control
onready var _energy_background := _stats.get_node("EnergyBackground") as Control


func set_actor(actor: Actor, portrait_clickable: bool) -> void:
	clear()
	_portrait_button.disabled = not portrait_clickable
	_portrait.texture = actor.portrait

	_name.text = actor.character_name

	_attack.text = str(actor.stats.attack)

	_stamina_bar.max_value = actor.stats.max_stamina
	_stamina_bar.value = actor.stats.stamina

	_set_energy_visible(actor.stats.max_energy > 0)

	_energy_bar.max_value = actor.stats.max_energy
	_energy_bar.value = actor.stats.energy

	_current_stamina.text = str(actor.stats.stamina)
	_current_energy.text = str(actor.stats.energy)


func clear() -> void:
	_portrait_button.disabled = true
	_portrait.texture = null
	_name.text = ""

	_stamina_bar.value = 0
	_energy_bar.value = 0

	_current_stamina.text = ""
	_current_energy.text = ""


func _set_energy_visible(visible: bool) -> void:
	_energy_icon.visible = visible
	_current_energy.visible = visible
	_energy_background.visible = visible


func _on_PortraitButton_pressed() -> void:
	emit_signal("portrait_pressed")
