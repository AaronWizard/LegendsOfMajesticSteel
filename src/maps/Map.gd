class_name Map
extends Node

export var tile_properties_set: PackedScene = null

onready var _ground: TileMap = $Ground
var _tile_properties_set: TilePropertiesSet = null


func _ready() -> void:
	if tile_properties_set:
		_tile_properties_set = tile_properties_set.instance()

	for a in get_actors():
		var actor := a as Actor
		assert(actor.map == self)


func get_rect() -> Rect2:
	return _ground.get_used_rect()


func get_pixel_rect() -> Rect2:
	var rect := _ground.get_used_rect()
	var rectpos := Vector2(rect.position * _ground.cell_size)
	var rectsize := Vector2(rect.size * _ground.cell_size)
	return Rect2(rectpos, rectsize)


func get_mouse_cell() -> Vector2:
	var mouse := _ground.get_local_mouse_position()
	var result := _ground.world_to_map(mouse)
	return result


func get_tile_name(cell: Vector2) -> String:
	var index := _ground.get_cellv(cell)
	var name := _ground.tile_set.tile_get_name(index)
	return name


func get_actors() -> Array:
	return _ground.get_children()


func get_actor_on_cell(cell: Vector2) -> Actor:
	var result: Actor = null

	for a in get_actors():
		var actor := a as Actor
		if actor.on_cell(cell):
			result = actor

	return result


func actor_can_enter_cell(actor: Actor, cell: Vector2,
		ignore_other_actors: bool = false) -> bool:
	var result := true

	if not get_rect().has_point(cell):
		result = false

	if result and not ignore_other_actors:
		var other_actor := get_actor_on_cell(cell)
		if other_actor and (other_actor != actor):
			result = false

	if result and _tile_properties_set:
		var tile_name := get_tile_name(cell)
		if tile_name:
			var properties := _tile_properties_set.get_properties(tile_name)
			if properties and properties.blocks_move:
				result = false
		else:
			result = false

	return result
