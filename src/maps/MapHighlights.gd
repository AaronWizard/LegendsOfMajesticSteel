class_name MapHighlights
extends Node

enum Tiles {
	WALK,
	TARGET,
	AOE,
}

onready var _highlights: TileMap = get_node("Highlights")


func set_walk_highlight(cells: Array) -> void:
	for c in cells:
		var cell: Vector2 = c
		_highlights.set_cellv(cell, Tiles.WALK)


func clear() -> void:
	_highlights.clear()
