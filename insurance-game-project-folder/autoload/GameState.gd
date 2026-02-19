extends Node

signal day_started(day: int)
signal day_ended(day: int)
signal turns_changed(turns_left: int)
signal player_changed()

const TURNS_PER_DAY := 12

var day: int = 1
var turns_left: int = TURNS_PER_DAY
var in_end_day: bool = false

var money: int = 0
var documents: Dictionary = {}

var player_max_hp: int = 30
var player_hp: int = 30
var player_power: int = 8
var player_defense: int = 2

func new_game():
	day = 1
	turns_left = TURNS_PER_DAY
	in_end_day = false
	money = 0
	documents = {}

	player_max_hp = 30
	player_hp = player_max_hp
	player_power = 8
	player_defense = 2

	day_started.emit(day)
	turns_changed.emit(turns_left)
	player_changed.emit()

func spend_turn():
	if in_end_day:
		return
	turns_left -= 1
	turns_changed.emit(turns_left)

	if turns_left <= 0:
		in_end_day = true
		day_ended.emit(day)

func continue_to_next_day():
	if not in_end_day:
		return
	in_end_day = false
	day += 1
	turns_left = TURNS_PER_DAY
	day_started.emit(day)
	turns_changed.emit(turns_left)

func damage_player(amount: int):
	player_hp = max(0, player_hp - amount)
	player_changed.emit()
