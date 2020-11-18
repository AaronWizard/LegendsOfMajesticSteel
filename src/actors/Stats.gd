tool
class_name Stats
extends Resource

const SPRITE_FRAME_COUNT := 4

export var texture: Texture setget set_texture

export var max_stamina := 1
export var attack := 1
export var move := 4

export(Array, Resource) var abilities := []

var portrait: AtlasTexture = null

func set_texture(new_texture: Texture) -> void:
	texture = new_texture

	if texture:
		portrait = AtlasTexture.new()
		portrait.atlas = texture
		portrait.region.position = Vector2.ZERO
		portrait.region.size \
				= texture.get_size() / Vector2(SPRITE_FRAME_COUNT, 1)
