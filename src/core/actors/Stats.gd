class_name Stats
extends Node

signal conditions_changed

signal damaged(amount, direction, standard_hit_anim)
signal healed(amount)

# Damage reduction turned into percentage based on this value
const DAMAGE_REDUCTION_RANGE := 100.0

var _base_stats := {}
var _conditions := []

var stamina: int

var is_alive: bool setget , get_is_alive

var max_stamina: int setget , get_max_stamina
var attack: int setget , get_attack
var move: int setget , get_move


func _ready() -> void:
	_base_stats[StatType.Type.DEFENCE] = 0.0


func init_from_def(def: ActorDefinition) -> void:
	set_base_stat(StatType.Type.MAX_STAMINA, def.max_stamina)
	set_base_stat(StatType.Type.ATTACK, def.attack)
	set_base_stat(StatType.Type.MOVE, def.move)


func set_base_stat(stat_type: int, value: int) -> void:
	_base_stats[stat_type] = value


func get_base_stat(stat_type: int) -> int:
	return _base_stats[stat_type] as int


func get_stat(stat_type: int) -> int:
	var base := _base_stats[stat_type] as int
	var add := 0

	for c in _conditions:
		var condition := c as Condition
		if condition.stat_modifiers.has(stat_type):
			var modifier := condition.stat_modifiers[stat_type] as StatModifier
			add += modifier.value

	return base + add


func get_stat_mod(stat_type: int) -> int:
	return get_stat(stat_type) - get_base_stat(stat_type)


func add_condition(condition: Condition) -> void:
	if _conditions.find(condition) == -1:
		_conditions.append(condition)

		assert(not condition.is_connected("finished", self, "remove_condition"))
		# warning-ignore:return_value_discarded
		condition.connect("finished", self, "remove_condition", [condition])

		emit_signal("conditions_changed")


func remove_condition(condition: Condition) -> void:
	if _conditions.find(condition) > -1:
		_conditions.erase(condition)

		if condition.is_connected("finished", self, "remove_condition"):
			condition.disconnect("finished", self, "remove_condition")

		emit_signal("conditions_changed")


func get_max_stamina() -> int:
	return get_stat(StatType.Type.MAX_STAMINA)


func get_max_energy() -> int:
	return get_stat(StatType.Type.MAX_ENERGY)


func get_attack() -> int:
	return get_stat(StatType.Type.ATTACK)


func get_move() -> int:
	return get_stat(StatType.Type.MOVE)


func start_battle() -> void:
	stamina = get_max_stamina()


func start_round() -> void:
	for c in _conditions:
		var condition := c as Condition
		condition.start_round()


# Get how much damage will be done with a given base damage
func damage_from_attack(base_damage: int) -> int:
	var dr := get_stat(StatType.Type.DEFENCE)
	var attack_mod := (DAMAGE_REDUCTION_RANGE - dr) / DAMAGE_REDUCTION_RANGE
	var reduced_damage := base_damage * attack_mod
	var final_damage := max(1, reduced_damage)
	return int(final_damage)


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
#   StatType.Type:
#   {
#     # Rounds left: stat mod
#     int: int
#   }
# }
# Stat mods with the same number of rounds left are combined.
# Perminant stat mods have a key of -1
func get_condition_stat_mods() -> Dictionary:
	var result := {}

	for c in _conditions:
		var condition := c as Condition
		for m in condition.stat_modifiers.values():
			var modifier := m as StatModifier

			var modifier_data: Dictionary
			if not result.has(modifier.type):
				modifier_data = {}
				result[modifier.type] = modifier_data
			else:
				modifier_data = result[modifier.type]

			var md_key: int
			if condition.definition.time_type \
					== ConditionDefinition.TimeType.ROUNDS:
				md_key = condition.rounds_left
			else:
				md_key = -1

			if modifier_data.has(md_key):
				modifier_data[md_key] += modifier.value
			else:
				modifier_data[md_key] = modifier.value

	return result
