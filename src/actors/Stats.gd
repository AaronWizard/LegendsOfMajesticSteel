class_name Stats

class Modifier:
	var stat: int
	var value: int

	func _init(new_stat: int, new_value: int) -> void:
		stat = new_stat
		value = new_value


signal stat_changed(stat)
signal stamina_changed(old_stamina, new_stamina)

enum StatType { MAX_STAMINA, ATTACK, MOVE, DAMAGE_REDUCTION }

# Damage reduction turned into percentage based on this value
const DAMAGE_REDUCTION_RANGE := 100.0

var _base_stats := {}
var _modifiers := []

var stamina: int

var is_alive: bool setget , get_is_alive

var max_stamina: int setget , get_max_stamina
var attack: int setget , get_attack
var move: int setget , get_move


func _init() -> void:
	_base_stats[StatType.DAMAGE_REDUCTION] = 0.0


func set_stat(stat_type: int, value: int) -> void:
	_base_stats[stat_type] = value


func add_modifier(mod: Modifier) -> void:
	_modifiers.append(mod)
	emit_signal("stat_changed", mod.stat)


func remove_modifier(mod: Modifier) -> void:
	_modifiers.erase(mod)
	emit_signal("stat_changed", mod.stat)


func get_max_stamina() -> int:
	return _get_stat(StatType.MAX_STAMINA)


func get_attack() -> int:
	return _get_stat(StatType.ATTACK)


func get_move() -> int:
	return _get_stat(StatType.MOVE)


func start_battle() -> void:
	stamina = get_max_stamina()


func get_is_alive() -> bool:
	return stamina > 0


# Get how much damage will be done with a given base damage
func damage_from_attack(base_damage: int) -> int:
	var dr := _get_stat(StatType.DAMAGE_REDUCTION)
	var attack_mod := (DAMAGE_REDUCTION_RANGE - dr) / DAMAGE_REDUCTION_RANGE
	var reduced_damage := base_damage * attack_mod
	var final_damage := max(1, reduced_damage)
	return int(final_damage)


func take_damage(base_damage: int) -> void:
	var damage := damage_from_attack(base_damage)
	_modify_stamina(-damage, true)


# Heal stamina by a percentage of max_stamina
func heal(heal_power: float, overflow: bool) -> void:
	var regained_stamina := int(ceil(get_max_stamina() * heal_power))
	_modify_stamina(regained_stamina, overflow)


func _get_stat(stat_type: int) -> int:
	var base := _base_stats[stat_type] as int
	var add := 0

	for m in _modifiers:
		var modifier := m as Modifier
		if modifier.stat == stat_type:
			add += modifier.value

	return base + add


func _modify_stamina(mod: int, overflow: bool) -> void:
	var old_stamina := stamina
	if overflow:
		stamina += mod
	else:
		stamina = int(clamp(stamina + mod, 0, get_max_stamina()))
	emit_signal("stamina_changed", old_stamina, stamina)
