extends Node
class_name CombatResolver

enum Move { ATTACK, BLOCK, DODGE, NONE }

static func does_a_beat_b(a: int, b: int) -> bool:
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

	var player_base: int = compute_damage(player_power, enemy_def)
	var enemy_base: int = compute_damage(enemy_power, player_def)

	var timing_result: String = "miss"
	var attack_multiplier: float = 0.0
	var defense_multiplier: float = 1.0

	if timing_quality >= 0.98:
		timing_result = "perfect"
		attack_multiplier = GameState.get_perfect_damage_multiplier()
		defense_multiplier = 0.0
	elif timing_quality >= 0.85:
		timing_result = "great"
		attack_multiplier = 1.5
		defense_multiplier = 0.35
	elif timing_quality >= 0.35:
		timing_result = "hit"
		attack_multiplier = 1.0
		defense_multiplier = 0.7
	else:
		timing_result = "miss"
		attack_multiplier = 0.0
		defense_multiplier = 1.0

	if player_move == Move.NONE and enemy_move == Move.NONE:
		return {
			"player_damage_taken": 0,
			"enemy_damage_taken": 0,
			"result": "nothing",
			"timing_result": timing_result
		}

	if player_move == Move.NONE:
		if enemy_move == Move.ATTACK:
			return {
				"player_damage_taken": enemy_base,
				"enemy_damage_taken": 0,
				"result": "enemy_win",
				"timing_result": timing_result
			}
		return {
			"player_damage_taken": 0,
			"enemy_damage_taken": 0,
			"result": "nothing",
			"timing_result": timing_result
		}

	if enemy_move == Move.NONE:
		return {
			"player_damage_taken": 0,
			"enemy_damage_taken": max(0, int(round(player_base * attack_multiplier))),
			"result": "player_win" if timing_result != "miss" else "player_miss",
			"timing_result": timing_result
		}

	if player_move == enemy_move:
		return {
			"player_damage_taken": max(0, int(round(1 * defense_multiplier))),
			"enemy_damage_taken": 0 if timing_result == "miss" else 1,
			"result": "tie",
			"timing_result": timing_result
		}

	if does_a_beat_b(player_move, enemy_move):
		return {
			"player_damage_taken": 0,
			"enemy_damage_taken": max(0, int(round(player_base * attack_multiplier))),
			"result": "player_win" if timing_result != "miss" else "player_miss",
			"timing_result": timing_result
		}
	else:
		var taken: int = max(1, int(round(enemy_base * defense_multiplier)))
		return {
			"player_damage_taken": taken,
			"enemy_damage_taken": 0,
			"result": "enemy_win",
			"timing_result": timing_result
		}
