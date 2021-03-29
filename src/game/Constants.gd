class_name Constants

const TILE_SIZE := 24
const TILE_SIZE_V := Vector2(TILE_SIZE, TILE_SIZE)

const TILE_HALF_SIZE_V := TILE_SIZE_V / 2

const SOUND_BUTTON := preload("res://src/ui/SoundButton.tscn")

static func create_sound_button() -> Button:
	return SOUND_BUTTON.instance() as Button
