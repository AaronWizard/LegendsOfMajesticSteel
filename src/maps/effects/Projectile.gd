class_name Projectile
extends Node2D

signal finished

export var speed := 8 # In cells per second
export var rotate_sprite := false

onready var start := $Start as TileObject
onready var end := $End as TileObject

onready var _sprite := $Sprite as Sprite
onready var _tween := $Tween as Tween
onready var _start_sound := $StartSound as AudioStreamPlayer


func start_animation() -> void:
	var start_pos := start.center_pixel_pos
	var end_pos := end.center_pixel_pos

	var dist := start.center_cell.distance_to(end.center_cell)
	var total_time := float(dist) / float(speed)

	if rotate_sprite:
		_sprite.rotation = end_pos.angle_to_point(start_pos)

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			_sprite, "position", start_pos, end_pos, total_time)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_Tween_tween_all_completed() -> void:
	if _start_sound.playing:
		yield(_start_sound, "finished")
	emit_signal("finished")
	queue_free()
