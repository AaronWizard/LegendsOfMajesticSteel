class_name ActorDetailsPanel
extends PanelContainer

signal closed

onready var _portrait := $Main/Header/PortraitMargin/PortraitBorder/Portrait \
		as TextureRect
onready var _name := $Main/Header/HeaderInfoMargin/VBoxContainer/Name as Label

onready var _stamina_info := $Main/Header/HeaderInfoMargin/VBoxContainer/ \
		Stamina as Control
onready var _current_stamina := _stamina_info.get_node("CurrentStamina") \
		as Label
onready var _max_stamina := _stamina_info.get_node("MaxStamina") as Label


func set_actor(actor: Actor) -> void:
	clear()

	_portrait.texture = actor.portrait
	_name.text = actor.character_name

	_current_stamina.text = str(actor.stats.stamina)
	_max_stamina.text = str(actor.stats.max_stamina)


func clear() -> void:
	_portrait.texture = null


func _on_Close_pressed() -> void:
	emit_signal("closed")
