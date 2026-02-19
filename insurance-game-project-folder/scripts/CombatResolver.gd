extends Node
class_name CombatResolver

enum Move { ATTACK, BLOCK, DODGE }

static func does_a_beat_b(a: int, b: int) -> bool:
	# For now this is basically RPS, we'll likely change it later to be better (especially since dodge shouldn't beat block)
	# ATTACK > DODGE, DODGE > BLOCK, BLOCK > ATTACK
	return (a == Move.ATTACK and b == Move.DODGE) \
		or (a == Move.DODGE and b == Move.BLOCK) \
		or (a == Move.BLOCK and b == Move.ATTACK)

static func compute_damage(attacker_power: int, defender_def: int) -> int:
	return max(1, attacker_power - defender_def)

static func resolve(player_move: int, enemy_move: int,
		player_power: int, player_def: int,
		enemy_power: int, enemy_def: int) -> Dictionary:

	if player_move == enemy_move:
		return {
			"player_damage_taken": 1,
			"enemy_damage_taken": 1,
			"result": "tie"
		}

	if does_a_beat_b(player_move, enemy_move):
		return {
			"player_damage_taken": 0,
			"enemy_damage_taken": compute_damage(player_power, enemy_def),
			"result": "player_win"
		}
	else:
		return {
			"player_damage_taken": compute_damage(enemy_power, player_def),
			"enemy_damage_taken": 0,
			"result": "enemy_win"
		}
