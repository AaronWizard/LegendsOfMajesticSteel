class_name TilePropertiesSet
extends Resource

export(Array, Resource) var properties := []


func get_properties(tile_name: String) -> TileProperties:
	var result: TileProperties = null

	for p in properties:
		var prop := p as TileProperties
		if tile_name in prop.tile_names:
			result = prop
			break

	return result
