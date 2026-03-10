extends Node

signal day_started(day: int)
signal day_ended(day: int)
signal turns_changed(turns_left: int)
signal player_changed()
signal player_died()
signal diseases_changed()
signal pending_disease_changed(disease_data: Dictionary)

const TURNS_PER_DAY: int = 12

enum Disease {
	RABIES,
	LEPROSY,
	TUBERCULOSIS,
	MIGRAINE,
	ANEMIA,
	HYPERTHYROIDISM,
	PNEUMONIA
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

var active_diseases: Array[int] = []
var pending_disease: int = -1

var leprosy_disabled_move: int = -1

func new_game() -> void:
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

	active_diseases.clear()
	pending_disease = -1
	leprosy_disabled_move = -1

	day_started.emit(day)
	turns_changed.emit(turns_left)
	player_changed.emit()
	diseases_changed.emit()
	pending_disease_changed.emit(get_pending_disease_data())

func spend_turn() -> void:
	if in_end_day:
		return

	turns_left -= 1

	if has_disease(Disease.TUBERCULOSIS):
		damage_player(1)

	turns_changed.emit(turns_left)

	if turns_left <= 0:
		in_end_day = true
		roll_pending_disease()
		day_ended.emit(day)

func continue_to_next_day() -> void:
	if not in_end_day:
		return

	if pending_disease != -1:
		active_diseases.append(pending_disease)

	has_completed_first_loop = true
	in_end_day = false
	day += 1
	turns_left = TURNS_PER_DAY

	_apply_disease_state()
	_heal_for_new_day()

	pending_disease = -1

	day_started.emit(day)
	turns_changed.emit(turns_left)
	player_changed.emit()
	diseases_changed.emit()
	pending_disease_changed.emit(get_pending_disease_data())

func damage_player(amount: int) -> void:
	player_hp = max(0, player_hp - max(0, amount))
	player_changed.emit()

	if player_hp == 0:
		player_died.emit()

func heal_player(amount: int) -> void:
	player_hp = min(player_max_hp, player_hp + max(0, amount))
	player_changed.emit()

func roll_pending_disease() -> void:
	var options: Array[int] = [
		Disease.RABIES,
		Disease.LEPROSY,
		Disease.TUBERCULOSIS,
		Disease.MIGRAINE,
		Disease.ANEMIA,
		Disease.HYPERTHYROIDISM,
		Disease.PNEUMONIA
	]

	pending_disease = options[randi() % options.size()]

	if pending_disease == Disease.LEPROSY:
		leprosy_disabled_move = randi() % 3

	pending_disease_changed.emit(get_pending_disease_data())

func has_disease(disease: int) -> bool:
	return active_diseases.has(disease)

func get_active_disease_names() -> Array[String]:
	var names: Array[String] = []
	for disease in active_diseases:
		names.append(str(_get_disease_data_for(disease).get("name", "Unknown")))
	return names

func get_active_disease_summary() -> String:
	if active_diseases.is_empty():
		return "None"
	return ", ".join(get_active_disease_names())

func get_pending_disease_data() -> Dictionary:
	if pending_disease == -1:
		return {
			"id": -1,
			"name": "None",
			"description": ""
		}
	return _get_disease_data_for(pending_disease)

func _get_disease_data_for(disease: int) -> Dictionary:
	match disease:
		Disease.RABIES:
			return {
				"id": disease,
				"name": "Rabies",
				"description": "+3 power. End-of-day healing reduced."
			}
		Disease.LEPROSY:
			return {
				"id": disease,
				"name": "Leprosy",
				"description": "One combat option is unusable.",
				"disabled_move": leprosy_disabled_move
			}
		Disease.TUBERCULOSIS:
			return {
				"id": disease,
				"name": "Tuberculosis",
				"description": "Lose 1 HP each turn. Timing bar moves slower."
			}
		Disease.MIGRAINE:
			return {
				"id": disease,
				"name": "Migraine",
				"description": "Smaller timing window. Perfect hits are stronger."
			}
		Disease.ANEMIA:
			return {
				"id": disease,
				"name": "Anemia",
				"description": "-2 power. Larger timing window."
			}
		Disease.HYPERTHYROIDISM:
			return {
				"id": disease,
				"name": "Hyperthyroidism",
				"description": "Faster timing bar. Perfect hits are stronger."
			}
		Disease.PNEUMONIA:
			return {
				"id": disease,
				"name": "Pneumonia",
				"description": "-1 defense. Reduced healing."
			}
		_:
			return {
				"id": -1,
				"name": "Unknown",
				"description": ""
			}

func _apply_disease_state() -> void:
	if has_disease(Disease.LEPROSY):
		if leprosy_disabled_move < 0:
			leprosy_disabled_move = randi() % 3
	else:
		leprosy_disabled_move = -1

func _heal_for_new_day() -> void:
	var base_heal: int = max(5, int(player_max_hp * 0.33))
	var heal_mult: float = get_end_of_day_heal_multiplier()
	var final_heal: int = max(1, int(round(base_heal * heal_mult)))
	heal_player(final_heal)

func get_modified_player_power() -> int:
	var bonus: int = 0

	if has_disease(Disease.RABIES):
		bonus += 3
	if has_disease(Disease.ANEMIA):
		bonus -= 2

	return max(1, player_power + bonus)

func get_modified_player_defense() -> int:
	var bonus: int = 0

	if has_disease(Disease.PNEUMONIA):
		bonus -= 1

	return max(0, player_defense + bonus)

func get_enemy_defense_bonus() -> int:
	return 0

func get_timing_speed_multiplier() -> float:
	var mult: float = 1.0

	if has_disease(Disease.TUBERCULOSIS):
		mult *= 0.8
	if has_disease(Disease.HYPERTHYROIDISM):
		mult *= 1.4

	return mult

func get_timing_sweet_spot_multiplier() -> float:
	var mult: float = 1.0

	if has_disease(Disease.MIGRAINE):
		mult *= 0.65
	if has_disease(Disease.ANEMIA):
		mult *= 1.35

	return mult

func get_perfect_damage_multiplier() -> float:
	var mult: float = 2.0

	if has_disease(Disease.MIGRAINE):
		mult += 0.25
	if has_disease(Disease.HYPERTHYROIDISM):
		mult += 0.25

	return mult

func get_end_of_day_heal_multiplier() -> float:
	var mult: float = 1.0

	if has_disease(Disease.RABIES):
		mult *= 0.5
	if has_disease(Disease.PNEUMONIA):
		mult *= 0.6

	return mult

func get_disabled_move() -> int:
	if has_disease(Disease.LEPROSY):
		return leprosy_disabled_move
	return -1
