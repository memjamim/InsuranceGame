extends Node
class_name CombatResolver

enum Move { ATTACK, BLOCK, DODGE }

static func does_a_beat_b(a: int, b: int) -> bool:
	# Still temporary RPS-style
	return (a == Move.ATTACK and b == Move.DODGE) \
		or (a == Move.DODGE and b == Move.BLOCK) \
		or (a == Move.BLOCK and b == Move.ATTACK)

static func compute_damage(attacker_power: int, defender_def: int) -> int:
	return max(1, attacker_power - defender_def)

static func resolve(
	player_move: int,
	enemy_move: int,
	player_power: int,
	player_def: int,
	enemy_power: int,
	enemy_def: int,
	timing_quality: float
) -> Dictionary:

	timing_quality = clamp(timing_quality, 0.0, 1.0)

	var player_base := compute_damage(player_power, enemy_def)
	var enemy_base := compute_damage(enemy_power, player_def)

	# Better timing = payoff
	var attack_multiplier: float = lerpf(0.5, 1.75, timing_quality)

	# Better timing also helps mitigate on defensive moves
	var defense_multiplier: float = 1.0
	if player_move == Move.BLOCK:
		defense_multiplier = lerpf(1.0, 0.35, timing_quality)
	elif player_move == Move.DODGE:
		defense_multiplier = lerpf(1.0, 0.2, timing_quality)

	if player_move == enemy_move:
		return {
			"player_damage_taken": max(0, int(round(1 * defense_multiplier))),
			"enemy_damage_taken": 1,
			"result": "tie"
		}

	if does_a_beat_b(player_move, enemy_move):
		return {
			"player_damage_taken": 0,
			"enemy_damage_taken": max(1, int(round(player_base * attack_multiplier))),
			"result": "player_win"
		}
	else:
		return {
			"player_damage_taken": max(1, int(round(enemy_base * defense_multiplier))),
			"enemy_damage_taken": 0,
			"result": "enemy_win"
		}
