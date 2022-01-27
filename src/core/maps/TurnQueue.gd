tool
class_name TurnQueue
extends YSort

signal actor_removed(actor, turn_index)

var _turn_index := -1


func _get_configuration_warning() -> String:
	var result := ""

	for c in get_children():
		var child := c as Actor
		if not child:
			result = "Children must be Actors"
			break

	return result


func _ready() -> void:
	if not Engine.editor_hint:
		_turn_index = -1

		var actors := get_children()
		actors.sort_custom(self, "_compare_actors")
		for a in actors:
			var actor := a as Node
			actor.raise()


func remove_child(node: Node) -> void:
	var index := node.get_index()
	.remove_child(node)
	if index < _turn_index:
		_turn_index -= 1
	emit_signal("actor_removed", node, index)


func next_actor() -> Actor:
	var is_first_round := _turn_index == -1
	_turn_index = (_turn_index + 1) % get_child_count()
	if _turn_index == 0:
		_start_round(is_first_round)

	return get_child(_turn_index) as Actor


# Actors have the following order:
# - Actors with higher agilities go first
# - Player actors go first
# - Actors earlier in the scene tree go first
static func _compare_actors(a: Actor, b: Actor) -> bool:
	return (a.stats.agility > b.stats.agility) \
		or ((a.faction == Actor.Faction.PLAYER) \
			and (a.faction != b.faction)) \
		or (a.get_index() < b.get_index())


func _start_round(is_first_round: bool) -> void:
	for a in get_children():
		var actor := a as Actor
		actor.start_round(is_first_round)
