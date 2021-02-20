class_name Stats

signal stat_changed(stat)
signal stamina_changed(old_stamina, new_stamina)

# Damage reduction turned into percentage based on this value
const DAMAGE_REDUCTION_RANGE := 100.0

var _base_stats := {}
var _conditions := []

var stamina: int

var is_alive: bool setget , get_is_alive

var max_stamina: int setget , get_max_stamina
var attack: int setget , get_attack
var move: int setget , get_move


func _init() -> void:
	_base_stats[StatType.Type.DAMAGE_REDUCTION] = 0.0


func set_base_stat(stat_type: int, value: int) -> void:
	_base_stats[stat_type] = value


func get_base_stat(stat_type: int) -> int:
	return _base_stats[stat_type] as int


func get_stat(stat_type: int) -> int:
	var base := _base_stats[stat_type] as int
	var add := 0

	for c in _conditions:
		var condition := c as ConditionEffect
		var modifiers := condition.get_modifiers_by_type(stat_type)

		for m in modifiers:
			var modifier := m as StatModifier
			if modifier.type == stat_type:
				add += modifier.value

	return base + add


func get_stat_mod(stat_type: int) -> int:
	return get_stat(stat_type) - get_base_stat(stat_type)


func add_condition_effect(condition: ConditionEffect) -> void:
	_conditions.append(condition)
	_condition_notify(condition)


func remove_condition_effect(condition: ConditionEffect) -> void:
	_conditions.erase(condition)
	_condition_notify(condition)


func get_max_stamina() -> int:
	return get_stat(StatType.Type.MAX_STAMINA)


func get_attack() -> int:
	return get_stat(StatType.Type.ATTACK)


func get_move() -> int:
	return get_stat(StatType.Type.MOVE)


func start_battle() -> void:
	stamina = get_max_stamina()


func get_is_alive() -> bool:
	return stamina > 0


# Get how much damage will be done with a given base damage
func damage_from_attack(base_damage: int) -> int:
	var dr := get_stat(StatType.Type.DAMAGE_REDUCTION)
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


func _condition_notify(condition: ConditionEffect) -> void:
	var changed_stats := {}

	for m in condition.stat_modifiers:
		var modifier := m as StatModifier
		changed_stats[modifier.type] = true

	for s in changed_stats:
		emit_signal("stat_changed", s)


func _modify_stamina(mod: int, overflow: bool) -> void:
	var old_stamina := stamina
	if overflow:
		stamina += mod
	else:
		stamina = int(clamp(stamina + mod, 0, get_max_stamina()))
	emit_signal("stamina_changed", old_stamina, stamina)
