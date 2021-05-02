class_name ScreenTransition
extends ColorRect

signal faded_in
signal faded_out


const _FADE_IN := "fade_in"
const _FADE_OUT := "fade_out"


onready var _anim := $AnimationPlayer as AnimationPlayer


func fade_in() -> void:
	_anim.play(_FADE_IN)


func fade_out() -> void:
	_anim.play(_FADE_OUT)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		_FADE_IN:
			emit_signal("faded_in")
		_FADE_OUT:
			emit_signal("faded_out")
