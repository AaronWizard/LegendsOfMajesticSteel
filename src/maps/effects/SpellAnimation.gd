class_name SpellAnimation
extends AnimatedSprite

export var cell: Vector2
export(Directions.Type) var direction: int = Directions.Type.EAST

func _ready() -> void:
	position = (cell * Constants.TILE_SIZE_V) + Constants.TILE_HALF_SIZE_V
	rotation = Directions.get_vector(direction).angle()
	play()


func _on_SpellAnimation_animation_finished() -> void:
	queue_free()
