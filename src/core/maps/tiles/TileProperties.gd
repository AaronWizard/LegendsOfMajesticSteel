class_name TileProperties, "res://assets/editor/tile_properties.png"
extends Resource

enum MoveType {
	CLEAR,
	ROUGH,
	BLOCK
}

enum PushType {
	CLEAR,
	ROUGH,
	BLOCK
}

enum DefenceType {
	NONE,
	COVER
}

export(Array, String) var tile_names := PoolStringArray()

export(MoveType) var move_type := MoveType.CLEAR
export(PushType) var push_type := PushType.CLEAR

export var blocks_attack := false

export(DefenceType) var self_defence_type := DefenceType.NONE


func blocks_move() -> bool:
	return move_type == MoveType.BLOCK


func move_is_rough() -> bool:
	return move_type == MoveType.ROUGH


func is_self_cover() -> bool:
	return self_defence_type == DefenceType.COVER
