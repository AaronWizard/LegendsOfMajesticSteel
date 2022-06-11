class_name StatType

enum Type {
	MAX_STAMINA,
	ATTACK,
	MOVE,
	DEFENCE,
	SPEED
}

const _MOD_ONLY_STATS := {
	Type.DEFENCE: true
}

static func is_mod_only(stat_type: int) -> bool:
	return _MOD_ONLY_STATS.has(stat_type)
