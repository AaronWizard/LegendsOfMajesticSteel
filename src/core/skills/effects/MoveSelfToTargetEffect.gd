class_name MoveSelfToTargetEffect, "res://assets/editor/move_self_effect.png"
extends SkillEffect

export var speed := 0.0 # Tiles per second

var _tween: Tween


func _ready() -> void:
	if speed > 0:
		_tween = Tween.new()
		add_child(_tween)


func _run_self(target_cell: Vector2, _source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	if not map.actor_can_enter_cell(source_actor, target_cell):
		push_error("'%s' can not enter cell at %s"
				% [source_actor.name, target_cell])
	assert(map.actor_can_enter_cell(source_actor, target_cell))

	if speed > 0:
		var offset := target_cell - source_actor.origin_cell
		var time := offset.length() / speed
		source_actor.set_facing(offset)
		# warning-ignore:return_value_discarded
		_tween.interpolate_property(source_actor, "cell_offset", Vector2.ZERO,
				offset, time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		# warning-ignore:return_value_discarded
		_tween.start()
		yield(_tween, "tween_all_completed")
		source_actor.cell_offset = Vector2.ZERO
	source_actor.origin_cell = target_cell
