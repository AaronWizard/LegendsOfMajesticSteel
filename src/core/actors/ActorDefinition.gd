class_name ActorDefinition
extends Resource

const SPRITE_FRAME_COUNT := 3

export var sprite: Texture
export var portrait: Texture setget , get_portrait

export var size := 1

export var max_stamina := 1
export var attack := 1
export var move := 4

export var attack_skill: PackedScene = null

export var skill0: PackedScene = null
export var skill1: PackedScene = null
export var skill2: PackedScene = null
export var skill3: PackedScene = null

var skills: Array setget , get_skills


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


func get_skills() -> Array:
	var result := []

	_check_skill(result, skill0)
	_check_skill(result, skill1)
	_check_skill(result, skill2)
	_check_skill(result, skill3)

	return result


func _check_skill(output_skills: Array, skill_scene: PackedScene) -> void:
	if skill_scene:
		output_skills.append(skill_scene)
