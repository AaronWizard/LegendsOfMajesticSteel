class_name SoundEffect, "res://assets/editor/sound_effect.png"
extends SkillEffect

export var stream: AudioStream


func _run_self(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, map: Map):
	var stream_player := AudioStreamPlayer.new()
	stream_player.stream = stream
	map.add_child(stream_player)
	
	stream_player.play()
	yield(stream_player, "finished")
	
	map.remove_child(stream_player)
	stream_player.queue_free()
