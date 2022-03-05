class_name Stats
extends Node

signal stat_changed(stat_type, old_value, new_value)

signal damaged(amount, direction, standard_hit_anim)
signal healed(amount)

# Keys are StatType.Type
# Values are integers
var _base_stats := {}

# Keys are StatType.Type
# Values are arrays of StatModifiers
var _stat_mods := {}

var stamina: int

var is_alive: bool setget , get_is_alive

var max_stamina: int setget , get_max_stamina
var attack: int setget , get_attack
var move: int setget , get_move
var speed: int setget , get_speed


func init_from_def(def: ActorDefinition) -> void:
	set_base_stat(StatType.Type.MAX_STAMINA, def.max_stamina)
	set_base_stat(StatType.Type.ATTACK, def.attack)
	set_base_stat(StatType.Type.MOVE, def.move)
	set_base_stat(StatType.Type.SPEED, def.speed)


func set_base_stat(stat_type: int, value: int) -> void:
	_base_stats[stat_type] = value


func get_base_stat(stat_type: int) -> int:
	return _base_stats[stat_type] as int


func get_stat(stat_type: int) -> int:
	var base := _base_stats[stat_type] as int

	var add_constant := 0
	var add_percent := 0.0

	var mods := _stat_mods[stat_type] as Array
	for m in mods:
		var mod := m as StatModifier
		add_constant += mod.add_constant
		add_percent += mod.add_percent

	return int(float(base + add_constant) * (1.0 + add_percent))


func get_stat_mod(stat_type: int) -> int:
	return get_stat(stat_type) - get_base_stat(stat_type)


func add_stat_mod(mod: StatModifier) -> void:
	var old_stat := get_stat(mod.stat_type)

	var mods: Array
	if _stat_mods.has(mod.stat_type):
		mods = _stat_mods[mod.stat_type] as Array
	else:
		mods = []
		_stat_mods[mod.stat_type] = mods

	if mods.find(mod) == -1:
		mods.append(mod)

		var new_stat := get_stat(mod.stat_type)
		if new_stat != old_stat:
			emit_signal("stat_changed", mod.stat_type, old_stat, new_stat)


func remove_stat_mod(mod: StatModifier) -> void:
	var old_stat := get_stat(mod.stat_type)

	if _stat_mods.has(mod.stat_type):
		var mods := _stat_mods[mod.stat_type] as Array
		mods.erase(mod)

		var new_stat := get_stat(mod.stat_type)
		if new_stat != old_stat:
			emit_signal("stat_changed", mod.stat_type, old_stat, new_stat)


func get_max_stamina() -> int:
	return get_stat(StatType.Type.MAX_STAMINA)


func get_max_energy() -> int:
	return get_stat(StatType.Type.MAX_ENERGY)


func get_attack() -> int:
	return get_stat(StatType.Type.ATTACK)


func get_move() -> int:
	return get_stat(StatType.Type.MOVE)


func get_speed() -> int:
	return get_stat(StatType.Type.SPEED)


func start_battle() -> void:
	stamina = get_max_stamina()


func start_round() -> void:
	for ms in _stat_mods.values():
		var mods := ms as Array
		for m in mods:
			var mod := m as StatModifier
			mod.start_round()


# Get how much damage will be done with a given base damage
func damage_from_attack(base_damage: int) -> int:
	var add_constant := 0
	var add_percent := 0.0

	var mods := _stat_mods[StatType.Type.DEFENCE] as Array
	for m in mods:
		var mod := m as StatModifier
		add_constant += mod.add_constant
		add_percent += mod.add_percent

	var reduced_damage := int(
			float(base_damage - add_constant) * (1.0 - add_percent)
	)
	var final_damage := int(max(1, reduced_damage))
	return final_damage


func take_damage(base_damage: int, direction: Vector2,
		standard_hit_anim := true) -> void:
	var damage := damage_from_attack(base_damage)
	stamina -= damage
	emit_signal("damaged", damage, direction, standard_hit_anim)


func instant_kill(direction: Vector2, standard_hit_anim := true) -> void:
	var old_stamina := stamina
	stamina = 0
	emit_signal("damaged", old_stamina, direction, standard_hit_anim)


# Heal stamina by a percentage of max_stamina
func heal(heal_power: float, overflow: bool) -> void:
	var regained_stamina := int(ceil(get_max_stamina() * heal_power))
	if overflow:
		stamina += regained_stamina
	else:
		stamina = int(clamp(stamina + regained_stamina, 0, get_max_stamina()))
	emit_signal("healed", regained_stamina)


func get_is_alive() -> bool:
	return stamina > 0


# {
#   Vector3: { # (StatType.Type, StatusEffectTiming.Type, rounds left)
#     add_constant: int
#     add_percent: float
#   }
# }
func get_condition_stat_mods() -> Dictionary:
	var result := {}

	for m in _stat_mods:
		var stat_mod := m as StatModifier

		var stat_type := stat_mod.stat_type
		var timing_type := stat_mod.timing_type
		var rounds := -1
		if timing_type == StatusEffectTiming.Type.ROUNDS:
			rounds = stat_mod.rounds

		var key := Vector3(stat_type, timing_type, rounds)

		var value: Dictionary
		if result.has(key):
			value = result[key] as Dictionary
		else:
			value = { add_constant = 0, add_float = 0.0 }
			result[key] = value

		value.add_constant += stat_mod.add_constant
		value.add_percent += stat_mod.add_percent

	return result
