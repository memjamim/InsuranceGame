extends Node

signal day_started(day: int)
signal day_ended(day: int)
signal turns_changed(turns_left: int)
signal player_changed()
signal player_died()
signal status_effect_changed(status_data: Dictionary)

const TURNS_PER_DAY := 12

enum StatusEffect {
	NONE,
	BATTLE_FOCUS,
	FOGGY_VISION,
	ADRENALINE,
	PANIC,
	RED_TAPE_SURGE,
	FLICKERING_LIGHTS
}

var day: int = 1
var turns_left: int = TURNS_PER_DAY
var in_end_day: bool = false
var has_completed_first_loop: bool = false

var money: int = 0
var documents: Dictionary = {}

var player_max_hp: int = 30
var player_hp: int = 30
var player_power: int = 8
var player_defense: int = 2

var current_status: int = StatusEffect.NONE
var pending_status: int = StatusEffect.NONE

func new_game():
	day = 1
	turns_left = TURNS_PER_DAY
	in_end_day = false
	has_completed_first_loop = false
	money = 0
	documents = {}

	player_max_hp = 30
	player_hp = player_max_hp
	player_power = 8
	player_defense = 2
	current_status = StatusEffect.NONE

	day_started.emit(day)
	turns_changed.emit(turns_left)
	player_changed.emit()
	status_effect_changed.emit(get_status_data())

func spend_turn():
	if in_end_day:
		return

	turns_left -= 1
	turns_changed.emit(turns_left)

	if turns_left <= 0:
		in_end_day = true
		roll_pending_status_effect()
		day_ended.emit(day)

func continue_to_next_day():
	if not in_end_day:
		return

	current_status = pending_status
	pending_status = StatusEffect.NONE
	has_completed_first_loop = true
	in_end_day = false
	day += 1
	turns_left = TURNS_PER_DAY

	day_started.emit(day)
	turns_changed.emit(turns_left)
	status_effect_changed.emit(get_status_data())

func damage_player(amount: int):
	player_hp = max(0, hp_after_modifiers(amount))
	player_changed.emit()
	if player_hp == 0:
		player_died.emit()

func hp_after_modifiers(incoming_damage: int) -> int:
	return player_hp - max(0, incoming_damage)

func roll_pending_status_effect():
	var options: Array[int] = [
		StatusEffect.BATTLE_FOCUS,
		StatusEffect.FOGGY_VISION,
		StatusEffect.ADRENALINE,
		StatusEffect.PANIC,
		StatusEffect.RED_TAPE_SURGE,
		StatusEffect.FLICKERING_LIGHTS
	]
	pending_status = options[randi() % options.size()]

func get_pending_status_data() -> Dictionary:
	var old := current_status
	current_status = pending_status
	var data := get_status_data()
	current_status = old
	return data

func get_status_data() -> Dictionary:
	match current_status:
		StatusEffect.BATTLE_FOCUS:
			return {
				"id": current_status,
				"name": "Battle Focus",
				"description": "+2 player power."
			}
		StatusEffect.FOGGY_VISION:
			return {
				"id": current_status,
				"name": "Foggy Vision",
				"description": "Timing sweet spot is smaller."
			}
		StatusEffect.ADRENALINE:
			return {
				"id": current_status,
				"name": "Adrenaline",
				"description": "Timing marker moves faster."
			}
		StatusEffect.PANIC:
			return {
				"id": current_status,
				"name": "Panic",
				"description": "-1 player defense."
			}
		StatusEffect.RED_TAPE_SURGE:
			return {
				"id": current_status,
				"name": "Red Tape Surge",
				"description": "Enemies gain +1 defense."
			}
		StatusEffect.FLICKERING_LIGHTS:
			return {
				"id": current_status,
				"name": "Flickering Lights",
				"description": "Visual distortion/flicker."
			}
		_:
			return {
				"id": StatusEffect.NONE,
				"name": "None",
				"description": "No active effect."
			}

func get_modified_player_power() -> int:
	var bonus := 0
	if current_status == StatusEffect.BATTLE_FOCUS:
		bonus += 2
	return player_power + bonus

func get_modified_player_defense() -> int:
	var bonus := 0
	if current_status == StatusEffect.PANIC:
		bonus -= 1
	return max(0, player_defense + bonus)

func get_enemy_defense_bonus() -> int:
	if current_status == StatusEffect.RED_TAPE_SURGE:
		return 1
	return 0

func get_timing_speed_multiplier() -> float:
	if current_status == StatusEffect.ADRENALINE:
		return 1.35
	return 1.0

func get_timing_sweet_spot_multiplier() -> float:
	if current_status == StatusEffect.FOGGY_VISION:
		return 0.6
	return 1.0
