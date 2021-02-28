class_name Projectile
extends Sprite

signal finished

export var start_cell: Vector2
export var end_cell: Vector2

export var start_offset := true
export var end_offset := true

export var speed := 8 # In cells per second

export var rotate_sprite := false

onready var _tween := $Tween as Tween


func _ready() -> void:
	var start_pos := (start_cell * Constants.TILE_SIZE_V)
	var end_pos := (end_cell * Constants.TILE_SIZE_V)

	if start_offset:
		start_pos += Constants.TILE_HALF_SIZE_V
	if end_offset:
		end_pos += Constants.TILE_HALF_SIZE_V

	var dist := start_cell.distance_to(end_cell)
	var total_time := float(dist) / float(speed)

	if rotate_sprite:
		rotation = end_pos.angle_to_point(start_pos)

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "position", start_pos, end_pos, total_time)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_Tween_tween_all_completed() -> void:
	emit_signal("finished")
	queue_free()
