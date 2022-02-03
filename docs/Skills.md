# Skills

A Skill is a special attack actors may take. Skills are defined with the following properties:

- **SkillRange**, for defining the target range of the skill
- A tree of **SkillEffect** nodes, for defining the behaviour of the skill

## SkillRange

### `get_range`

`get_range(source_cell: Vector2, source_actor: Actor, map: Map) -> Array`

#### Parameters

- `source_cell`: The position of the source actor
- `source_actor`: The actor using the skill the range applies to
- `map`: The current map

#### Result

An array of Vector2s representing the cells in the range.

## SkillEffect

### `get_target_info`

`get_target_info(target_cell: Vector2, source_cell: Vector2, source_actor: Actor, map: Map) -> TargetingData.TargetInfo`

#### Parameters

- `target_cell`: The cell targeted by the skill effect
- `source_cell`: The source of the skill effect
  - May not be the same cell as the source actor's origin cell
- `source_actor`: The source actor of the skill effect
- `map`: The current map

#### Result

Target info about the skill.

### `_run_self`

`_run_self(target_cell: Vector2, source_cell: Vector2, source_actor: Actor, map: Map) -> void`

#### Parameters

- `target_cell`: The cell targeted by the skill effect
- `source_cell`: The source of the skill effect
  - May not be the same cell as the source actor's origin cell
- `source_actor`: The source actor of the skill effect
- `map`: The current map

#### Result

Runs the skill effect.

## SkillEffectWrapper

`_child_effect() -> SkillEffect`

Gets the child effect.

`_get_child_target_info(target_cell: Vector2, source_cell: Vector2, source_actor: Actor, map: Map) -> TargetingData.TargetInfo`

Gets the targeting info of the child effect.

`_run_child_effect(target_cell: Vector2, source_cell: Vector2, source_actor: Actor, map: Map) -> void`

Runs the child effect.
