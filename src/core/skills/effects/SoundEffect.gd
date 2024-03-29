class_name SoundEffect, "res://assets/editor/sound_effect.png"
extends SkillEffect

export var stream: AudioStream


func _run_self(_target_cell: Vector2, _source_cell: Vector2,
		source_actor: Actor) -> void:
	var stream_player := AudioStreamPlayer.new()
	stream_player.stream = stream
	stream_player.bus = Constants.SOUND_BUS

	source_actor.map.add_child(stream_player)

	stream_player.play()
	yield(stream_player, "finished")

	source_actor.map.remove_child(stream_player)
	stream_player.queue_free()
