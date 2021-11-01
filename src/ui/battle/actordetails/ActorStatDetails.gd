tool
class_name ActorStatDetails
extends VBoxContainer

export var stat_icon: Texture = null setget set_stat_icon
export var stat_label := "" setget set_stat_label

onready var _icon := $Header/Icon as TextureRect
onready var _label := $Header/Label as Label

onready var _stat := $Values/Stat as Label
onready var _mod := $Values/Mod as Label


func _ready() -> void:
	set_stat_icon(stat_icon)
	set_stat_label(stat_label)


func set_stat_icon(value: Texture) -> void:
	stat_icon = value
	if _icon:
		_icon.texture = stat_icon


func set_stat_label(value: String) -> void:
	stat_label = value
	if _label:
		_label.text = value


func set_stat_values(stats: Stats, stat_type: int) -> void:
	var stat_value := stats.get_stat(stat_type)
	var stat_mod := stats.get_stat_mod(stat_type)

	_stat.text = str(stat_value)
	if stat_mod == 0:
		_mod.text = ""
	else:
		_mod.text = "(%s)" % stat_mod
