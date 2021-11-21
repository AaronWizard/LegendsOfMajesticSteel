class_name AIScoredAction

const _KILL_WEIGHT := 2.0
const _STAT_MOD_WEIGHT := 0.25

const _DEFENSIVE_TERRAIN_WEIGHT := 0.5
const _ENEMY_DISTANCE_APPROACH_WEIGHT := 0.5

const _RANDOM_RANGE := 0.15

var score: float

var skill: Skill
var targeting_data: TargetingData
var source_cell: Vector2
var target_cell: Vector2

var _actor: Actor
var _map: Map


static func new_skill_action(new_actor: Actor, new_map: Map,
		new_skill: Skill, new_targeting_data: TargetingData,
		new_target_cell: Vector2) -> AIScoredAction:
	var instance = load("res://src/control/AIScoredAction.gd").new(
		new_actor, new_map, new_skill, new_targeting_data,
		new_targeting_data.source_cell, new_target_cell
	) as AIScoredAction
	assert(instance.targeting_data.valid_targets.has(instance.target_cell))
	return instance


static func new_move_action(new_actor: Actor, new_map: Map,
		new_source_cell: Vector2) -> AIScoredAction:
	var instance = load("res://src/control/AIScoredAction.gd").new(
		new_actor, new_map, null, null, new_source_cell, Vector2.ZERO
	) as AIScoredAction
	return instance


func _init(new_actor: Actor, new_map: Map, new_skill: Skill,
		new_targeting_data: TargetingData, new_source_cell: Vector2,
		new_target_cell: Vector2) -> void:
	_actor = new_actor
	_map = new_map

	skill = new_skill
	targeting_data = new_targeting_data
	source_cell = new_source_cell
	target_cell = new_target_cell

	assert(
		(targeting_data == null)
		or (source_cell == targeting_data.source_cell)
	)

	_calculate_score()


func _calculate_score() -> void:
	score = 0

	if skill:
		_score_skill_source_cell()
		_score_damage()
		_score_conditions()
	else:
		_score_move_cell()

	score += randf() * _RANDOM_RANGE


func _score_move_cell() -> void:
	var enemy_dist := _average_enemy_distance()
	score += 1 - enemy_dist


func _score_skill_source_cell() -> void:
	if _map.is_defensive_terrain_at_cell(_actor, source_cell):
		score += _DEFENSIVE_TERRAIN_WEIGHT

	var enemy_dist := _average_enemy_distance()
	score += enemy_dist * _ENEMY_DISTANCE_APPROACH_WEIGHT


func _average_enemy_distance() -> float:
	var result := 0.0

	var enemies := _map.get_actors_by_faction(Actor.Faction.PLAYER)
	var max_dist_sqr := -1.0
	for e in enemies:
		var enemy := e as Actor
		var dist_sqr := enemy.origin_cell.distance_squared_to(source_cell)
		result += dist_sqr
		if (max_dist_sqr == -1.0) or (max_dist_sqr < dist_sqr):
			max_dist_sqr = dist_sqr
	result /= enemies.size()
	result /= max_dist_sqr

	assert(result >= 0)
	assert(result <= 1)

	return result


func _score_damage() -> void:
	var predicted_damage := targeting_data.get_predicted_damage(target_cell)
	for a in predicted_damage:
		var other_actor := a as Actor
		var damage := predicted_damage[other_actor] as int

		var stamina := other_actor.stats.stamina
		var damage_score := clamp(float(damage) / float(stamina), -1, 1)

		if abs(damage_score) == -1:
			damage_score *= _KILL_WEIGHT
		if other_actor.faction != _actor.faction:
			damage_score *= -1

		score += damage_score


func _score_conditions() -> void:
	var predicted_conditions := targeting_data.get_predicted_conditions(
			target_cell)
	for a in predicted_conditions:
		var other_actor := a as Actor
		var conditions := predicted_conditions[other_actor] as Array

		for c in conditions:
			var condition := c as ConditionDefinition

			for m in condition.stat_modifiers:
				var modifier := m as StatModifier

				var current_stat := other_actor.stats.get_stat(modifier.type)
				var modifier_score := clamp(
						float(modifier.value) / float(current_stat), -1, 1
				)

				if other_actor.faction != _actor.faction:
					modifier_score *= -1

				score += modifier_score * _STAT_MOD_WEIGHT
