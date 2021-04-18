class_name TilePropertiesSet, "res://assets/editor/tile_properties_set.png"
extends Resource

export(Array, Resource) var properties := []


func get_properties(tile_name: String) -> TileProperties:
	var result: TileProperties = null

	for p in properties:
		var props := p as TileProperties
		if tile_name in props.tile_names:
			result = props
			break

	return result
