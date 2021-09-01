class_name VictoryText
extends Node

signal victory_text_shown


onready var anim := $AnimationPlayer as AnimationPlayer


func show_victory_text() -> void:
	anim.play("ShowVictoryText")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("victory_text_shown")
