tool
class_name MapAnimation
extends TileObject

signal finished

export var anim_rotation: float setget set_anim_rotation, get_anim_rotation
export var wait_for_sound := false

onready var _anim := $Center/Offset/AnimatedSprite as AnimatedSprite
onready var _sound := $Sound as AudioStreamPlayer


func _ready() -> void:
	if not Engine.editor_hint:
		set_anim_rotation(anim_rotation)


func set_anim_rotation(radians: float) -> void:
	if _anim:
		_anim.rotation = radians


func get_anim_rotation() -> float:
	var result := 0.0
	if _anim:
		result = _anim.rotation
	return result


func start_animation() -> void:
	_anim.show()
	_anim.play()


func _on_AnimatedSprite_animation_finished() -> void:
	_anim.stop()
	_anim.hide()

	if wait_for_sound and _sound.playing:
		yield(_sound, "finished")

	emit_signal("finished")

	if _sound.playing:
		yield(_sound, "finished")

	queue_free()
