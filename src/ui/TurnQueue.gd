class_name TurnQueue
extends PanelContainer


const _ENEMY_TURN_ICON := preload("res://assets/graphics/ui/icons/enemy_turn.png")
const _PLAYER_TURN_ICON := preload("res://assets/graphics/ui/icons/player_turn.png")


onready var _icons := $ScrollContainer/Icons as Container


func set_queue(factions: Array) -> void:
	clear()

	for f in factions:
		var faction := f as int
		match faction:
			Actor.Faction.PLAYER:
				_add_icon(_PLAYER_TURN_ICON)
			Actor.Faction.ENEMY:
				_add_icon(_ENEMY_TURN_ICON)
			_:
				assert(false)


func clear():
	for c in _icons.get_children():
		var child := c as Node
		child.queue_free()


func _add_icon(texture: Texture) -> void:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.rect_min_size = texture.get_size()
	_icons.add_child(icon)
