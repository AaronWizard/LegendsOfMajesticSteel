class_name Stats
extends Node

export var move: int = 4

export var attack := 1
export var defence := 1


static func get_attack_power(attacker: Stats, defender: Stats) -> int:
	var power := (float(attacker.attack) / float(defender.defence * 4))
	power = floor(power * Constants.MAX_STAMINA)
	return int(power)
