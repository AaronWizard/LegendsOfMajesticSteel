class_name ActorDefinition
extends Resource

const SPRITE_FRAME_COUNT := 4

export var sprite: Texture
export var portrait: Texture setget , get_portrait

export var rect_size := Vector2.ONE

export var max_stamina := 1
export var attack := 1
export var move := 4

# First skill is actor's standard attack
export(Array, Resource) var skills := []


func get_portrait() -> Texture:
	var result: Texture = null
	if portrait:
		result = portrait
	elif not Engine.editor_hint:
		result = _get_portrait_from_sprite()

	return result


func _get_portrait_from_sprite() -> Texture:
	var result: AtlasTexture = null

	if sprite:
		result = AtlasTexture.new()
		result.atlas = sprite
		result.region.position = Vector2.ZERO
		result.region.size = sprite.get_size() / Vector2(SPRITE_FRAME_COUNT, 1)

		if result.region.size.x > Constants.TILE_SIZE:
			var diff_x := result.region.size.x - Constants.TILE_SIZE
			result.region.size.x = Constants.TILE_SIZE
			result.region.position.x += diff_x / 2
		if result.region.size.y > Constants.TILE_SIZE:
			result.region.size.y = Constants.TILE_SIZE

	return result
