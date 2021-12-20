class_name ActionMenu
extends Node2D

signal attack_selected
signal skill_selected(skill_index)
signal wait_selected

const _ANIM_TIME := 0.15
const _BUTTON_WIDTH := Constants.TILE_SIZE
const _BUTTON_MARGIN := 4

var is_open: bool setget , get_is_open

onready var _skills := $Skills as Node2D

onready var _attack_button := $AttackPos/Attack as Button
onready var _wait_button := $WaitPos/Wait as Control

onready var _attack_pos := $AttackPos as Node2D
onready var _wait_pos := $WaitPos as Node2D

onready var _attack_pos_end := $AttackPosEnd as Node2D
onready var _wait_pos_end := $WaitPosEnd as Node2D
onready var _skills_end := $SkillsEnd as Node2D

onready var _tween := $Tween as Tween

var _is_open := false
var _have_attack := false


func _ready() -> void:
	_attack_button.visible = false
	_wait_button.visible = false
	_skills.visible = false


func set_actions(attack_skill: Skill, skills: Array) \
		-> void:
	_set_attack(attack_skill)
	_set_skills(skills)


func get_is_open() -> bool:
	return _is_open


func open() -> void:
	_is_open = true
	StandardSounds.play_select()

	_attack_button.visible = _have_attack
	_wait_button.visible = true
	_skills.visible = true
	_animate_opening()
	yield(_tween, "tween_all_completed")


func close(with_sound: bool) -> void:
	_is_open = false
	if with_sound:
		StandardSounds.play_cancel()

	_animate_closing()
	yield(_tween, "tween_all_completed")
	_attack_button.visible = false
	_wait_button.visible = false
	_skills.visible = false


func clear_skills() -> void:
	for s in _skills.get_children():
		var skill_button_pos := s as Node
		_skills.remove_child(skill_button_pos)
		skill_button_pos.queue_free()


func _set_attack(attack_skill: Skill) -> void:
	_have_attack = attack_skill != null
	if attack_skill:
		_attack_button.icon = attack_skill.icon


func _set_skills(skills: Array) -> void:
	clear_skills()

	for i in range(skills.size()):
		var index := i as int
		var skill := skills[index] as Skill

		var button := SoundButton.new()

		# warning-ignore:return_value_discarded
		button.connect("pressed", self, "_on_Skill_pressed", [index])

		var icon := TextureRect.new()
		icon.texture = skill.icon
		button.add_child(icon) # If button is disabled, avoid icon tinting
		icon.margin_left = _BUTTON_MARGIN
		icon.margin_top = _BUTTON_MARGIN
		icon.margin_right = -_BUTTON_MARGIN
		icon.margin_bottom = -_BUTTON_MARGIN

		button.disabled = skill.current_cooldown > 0
		if button.disabled:
			var label := Label.new()

			label.text = str(skill.current_cooldown)
			label.align = Label.ALIGN_RIGHT
			button.add_child(label)

			label.rect_size = Vector2.ZERO
			label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			label.margin_left = -label.rect_size.x
			label.margin_top = -label.rect_size.y
			label.margin_right = 0
			label.margin_bottom = 0

		var skill_button_pos := Node2D.new()
		skill_button_pos.add_child(button)

		# warning-ignore:integer_division
		button.margin_left = -_BUTTON_WIDTH / 2
		# warning-ignore:integer_division
		button.margin_top = -_BUTTON_WIDTH / 2
		# warning-ignore:integer_division
		button.margin_right = _BUTTON_WIDTH / 2
		# warning-ignore:integer_division
		button.margin_bottom = _BUTTON_WIDTH / 2

		_skills.add_child(skill_button_pos)


func _animate_opening() -> void:
	_queue_animate_pos(_attack_pos, Vector2.ZERO, _attack_pos_end.position)
	_queue_animate_pos(_wait_pos, Vector2.ZERO, _wait_pos_end.position)

	if _skills.get_child_count() > 0:
		_queue_animate_pos(_skills, Vector2.ZERO, _skills_end.position)

	for i in range(_skills.get_child_count()):
		var index := i as int
		var skill_button_pos := _skills.get_child(index) as Node2D
		var end_pos := _get_open_skill_pos(index)
		_queue_animate_pos(skill_button_pos, Vector2.ZERO, Vector2(end_pos, 0))

	# warning-ignore:return_value_discarded
	_tween.start()


func _animate_closing() -> void:
	_queue_animate_pos(_attack_pos, _attack_pos_end.position, Vector2.ZERO)
	_queue_animate_pos(_wait_pos, _wait_pos_end.position, Vector2.ZERO)

	if _skills.get_child_count() > 0:
		_queue_animate_pos(_skills, _skills_end.position, Vector2.ZERO)

	for s in _skills.get_children():
		var skill_button_pos := s as Node2D
		_queue_animate_pos(skill_button_pos,
				skill_button_pos.position, Vector2.ZERO)

	# warning-ignore:return_value_discarded
	_tween.start()


func _queue_animate_pos(node: Node2D, start: Vector2, end: Vector2) -> void:
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(node, "position", start, end, _ANIM_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT)


func _get_open_skill_pos(index: int) -> int:
	var skill_count := _skills.get_child_count()
	var total_width := (skill_count - 1) * _BUTTON_WIDTH
	# warning-ignore:integer_division
	var result := (index * _BUTTON_WIDTH) - (total_width / 2)

	return result


func _on_Attack_pressed() -> void:
	if not _tween.is_active():
		emit_signal("attack_selected")


func _on_Skill_pressed(index: int) -> void:
	if not _tween.is_active():
		emit_signal("skill_selected", index)


func _on_Wait_pressed() -> void:
	if not _tween.is_active():
		emit_signal("wait_selected")
