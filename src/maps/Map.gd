class_name Map
extends Node

signal actor_dying(actor)
signal actor_removed(actor)

enum Decal { BLOOD_SPLATTER = 0 }

export var tile_properties_set: Resource

onready var _ground := $Ground as TileMap
onready var _decals := $Decals as TileMap
onready var _actors := $Actors as Node
onready var _effects := $Effects as Node

# Because I can't use TilePropertiesSet as an export hint
var _tile_properties_set: TilePropertiesSet = null


func _ready() -> void:
	if tile_properties_set:
		_tile_properties_set = tile_properties_set as TilePropertiesSet

	for a in get_actors():
		var actor := a as Actor
		# warning-ignore:return_value_discarded
		actor.connect("dying", self, "_actor_dying", [actor], CONNECT_ONESHOT)
		# warning-ignore:return_value_discarded
		actor.connect("died", self, "remove_actor", [actor], CONNECT_ONESHOT)


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


func get_screen_cell_pos(cell: Vector2) -> Vector2:
	return _ground.map_to_world(cell) \
			+ _ground.get_global_transform_with_canvas().origin \
			+ (_ground.cell_size / 2)


func get_tile_name(cell: Vector2) -> String:
	var index := _ground.get_cellv(cell)
	var name := _ground.tile_set.tile_get_name(index)
	return name


func get_tile_properties(cell: Vector2) -> TileProperties:
	var result: TileProperties = null

	if _tile_properties_set:
		var tile_name := get_tile_name(cell)
		if tile_name:
			result = _tile_properties_set.get_properties(tile_name)

	return result


func get_cell_move_cost(cell: Vector2) -> int:
	var result := 1
	var properties := get_tile_properties(cell)
	if properties:
		result = properties.move_cost
	return result


func add_decal(decal: int, cell: Vector2) -> void:
	_decals.set_cellv(cell, decal)


func get_actors() -> Array:
	return _actors.get_children()


func get_actor_on_cell(cell: Vector2) -> Actor:
	var result: Actor = null

	for a in get_actors():
		var actor := a as Actor
		if actor.on_cell(cell):
			result = actor

	return result


func actor_can_enter_cell(actor: Actor, cell: Vector2,
		ignore_allied_actors: bool = false) -> bool:
	var result := true

	var cells := actor.get_covered_cells_at_cell(cell)
	for c in cells:
		var covered := c as Vector2
		if not get_rect().has_point(covered):
			result = false

		if result:
			var other_actor := get_actor_on_cell(covered)
			if other_actor and (other_actor != actor):
				result = ignore_allied_actors \
						and (other_actor.faction == actor.faction)

		if result:
			var properties := get_tile_properties(covered)
			if properties:
				result = !properties.blocks_move

	return result


func remove_actor(actor: Actor) -> void:
	assert(actor in _actors.get_children())
	_actors.remove_child(actor)
	emit_signal("actor_removed", actor)


func add_effect(effect: Node2D) -> void:
	_effects.add_child(effect)


func _actor_dying(actor: Actor) -> void:
	for c in actor.get_covered_cells():
		var cell := c as Vector2
		add_decal(Decal.BLOOD_SPLATTER, cell)
	emit_signal("actor_dying", actor)
