tool
extends TileSet

func _is_tile_bound(_drawn_id: int, neighbor_id: int) -> bool:
	return neighbor_id == -1
