class_name TilePropertiesSet
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


func move_cost(tile_name: String) -> int:
	var result := 1

	var props := get_properties(tile_name)
	if props:
		result = props.move_cost

	return result
