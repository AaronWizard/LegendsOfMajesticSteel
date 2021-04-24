tool
class_name TerrainTileSet, "res://assets/editor/tile_properties_set.png"
extends TileSet

export(Array, Resource) var tile_properties := []


func _is_tile_bound(_drawn_id: int, neighbor_id: int) -> bool:
	return neighbor_id == -1


func get_properties(tile_name: String) -> TileProperties:
	var result: TileProperties = null

	for p in tile_properties:
		var props := p as TileProperties
		if tile_name in props.tile_names:
			result = props
			break

	return result
