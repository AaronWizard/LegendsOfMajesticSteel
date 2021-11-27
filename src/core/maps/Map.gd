tool
class_name Map, "res://assets/editor/map.png"
extends Node2D

signal actor_dying(actor)
signal actor_removed(actor)

enum Decal { BLOOD_SPLATTER = 0 }

const MOVE_COST_CLEAR := 1
const MOVE_COST_ROUGH := 2

const _COVER_EFFECT := preload("res://resources/data/conditions/Cover.tres")

var _COVER_CONDITION := Condition.new(_COVER_EFFECT)

onready var _ground := $Ground as TileMap
onready var _decals := $Decals as TileMap
onready var _actors := $Actors as Node
onready var _effects := $Effects as Node

var _actor_positions := {}


func _ready() -> void:
	if not Engine.editor_hint:
		for a in get_actors():
			var actor := a as Actor
			# warning-ignore:return_value_discarded
			actor.connect("origin_cell_changed", self,
					"_actor_origin_cell_changed", [actor])
			# warning-ignore:return_value_discarded
			actor.connect("dying", self, "_actor_dying", [actor],
					CONNECT_ONESHOT)
			# warning-ignore:return_value_discarded
			actor.connect("died", self, "remove_actor", [actor],
					CONNECT_ONESHOT)

			for c in actor.covered_cells:
				var cell := c as Vector2
				_actor_positions[cell] = actor

		update_terrain_effects()


func _get_configuration_warning() -> String:
	var result := ""

	if $Ground and not (($Ground as TileMap).tile_set is TerrainTileSet):
		result = "Ground tile set needs to be a TerrainTileSet"

	return result


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


func get_tile_properties(cell: Vector2) -> TileProperties:
	var result: TileProperties = null

	var tileset := _ground.tile_set as TerrainTileSet
	var tile_name := get_tile_name(cell)
	if tile_name:
		result = tileset.get_properties(tile_name)

	return result


func get_cell_move_cost(cell: Vector2, actor: Actor) -> int:
	var result := MOVE_COST_CLEAR

	for c in actor.get_covered_cells_at_cell(cell):
		var covered := c as Vector2
		var properties := get_tile_properties(covered)
		if properties:
			assert(not properties.blocks_move())
			if properties.move_is_rough():
				result = MOVE_COST_ROUGH
				break

	return result


func get_cell_push_cost(cell: Vector2, actor: Actor) -> int:
	var result := MOVE_COST_CLEAR

	for c in actor.get_covered_cells_at_cell(cell):
		var covered := c as Vector2
		var properties := get_tile_properties(covered)
		if properties:
			assert(not properties.blocks_push())
			if properties.push_is_rough():
				result = MOVE_COST_ROUGH
				break

	return result


func is_defensive_terrain_at_cell(actor: Actor, cell: Vector2) -> bool:
	var defensive_tiles := 0
	var clear_tiles := 0

	for c in actor.get_covered_cells_at_cell(cell):
		var covered := c as Vector2
		var properties := get_tile_properties(covered)
		if properties and properties.is_self_cover():
			defensive_tiles += 1
		else:
			clear_tiles += 1

	return defensive_tiles > clear_tiles


func add_decal(decal: int, cell: Vector2) -> void:
	_decals.set_cellv(cell, decal)


func get_actors() -> Array:
	return _actors.get_children()


func get_actors_by_faction(faction: int) -> Array:
	var all_actors := get_actors()
	var result := []
	for a in all_actors:
		var actor := a as Actor
		if actor.faction == faction:
			result.append(actor)

	return result


func get_actor_on_cell(cell: Vector2) -> Actor:
	var result: Actor = null

	if _actor_positions.has(cell):
		var actor := _actor_positions[cell] as Actor
		# Lazy updates to _actor_positions
		if actor.on_cell(cell):
			result = actor
		else:
			# warning-ignore:return_value_discarded
			_actor_positions.erase(cell)

	return result


func get_actors_on_cells(cells: Array) -> Array:
	var result := {}

	for c in cells:
		var cell := c as Vector2
		var actor := get_actor_on_cell(cell)
		if actor:
			result[actor] = true

	return result.keys()


func actor_can_enter_cell(actor: Actor, cell: Vector2,
		ignore_allied_actors: bool = false) -> bool:
	var result := true

	var cells := actor.get_covered_cells_at_cell(cell)
	for c in cells:
		var covered := c as Vector2
		if not get_rect().has_point(covered):
			result = false
			break
		else:
			var other_actor := get_actor_on_cell(covered)
			var is_blocking_actor := \
					(other_actor != null) and (other_actor != actor) \
					and (not ignore_allied_actors \
						or (other_actor.faction != actor.faction))
			if is_blocking_actor:
				result = false
				break
			else:
				var properties := get_tile_properties(covered)
				if properties and properties.blocks_move():
					result = false
					break

	return result


func actor_can_be_pushed_into_cell(actor: Actor, cell: Vector2) -> bool:
	var result := true

	var cells := actor.get_covered_cells_at_cell(cell)
	for c in cells:
		var covered := c as Vector2
		if not get_rect().has_point(covered):
			result = false
			break
		else:
			var other_actor := get_actor_on_cell(covered)
			var is_blocking_actor := \
					(other_actor != null) and (other_actor != actor)

			if is_blocking_actor:
				result = false
				break
			else:
				var properties := get_tile_properties(covered)
				if properties and properties.blocks_push():
					result = false
					break

	return result


func remove_actor(actor: Actor) -> void:
	assert(actor in _actors.get_children())
	_actors.remove_child(actor)
	emit_signal("actor_removed", actor)

	for c in actor.covered_cells:
		var cell := c as Vector2
		# warning-ignore:return_value_discarded
		_actor_positions.erase(cell)


func reset_actor_virtual_origins() -> void:
	for a in get_actors():
		var actor := a as Actor
		actor.reset_virtual_origin()


func update_terrain_effects() -> void:
	for a in get_actors():
		var actor := a as Actor
		if _on_defensive_terrain(actor):
			actor.stats.add_condition(_COVER_CONDITION)
		else:
			actor.stats.remove_condition(_COVER_CONDITION)


func add_effect(effect: Node2D) -> void:
	_effects.add_child(effect)


func _actor_origin_cell_changed(actor: Actor) -> void:
	for c in actor.covered_cells:
		var cell := c as Vector2
		_actor_positions[cell] = actor


func _actor_dying(actor: Actor) -> void:
	for c in actor.covered_cells:
		var cell := c as Vector2
		add_decal(Decal.BLOOD_SPLATTER, cell)
	emit_signal("actor_dying", actor)


func _on_defensive_terrain(actor: Actor) -> bool:
	return is_defensive_terrain_at_cell(actor, actor.origin_cell)
