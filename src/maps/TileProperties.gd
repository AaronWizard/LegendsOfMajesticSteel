class_name TileProperties
extends Resource

export(Array, String) var tile_names := PoolStringArray()
export var move_cost := 1
export(float, -1, 1, 0.1) var defence := 0

var blocks_move: bool setget , get_blocks_move


func get_blocks_move() -> bool:
	return move_cost <= 0
