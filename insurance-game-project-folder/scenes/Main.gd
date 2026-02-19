extends Node

@onready var room: Room = $Room

func _ready():
	GameState.new_game()
	_load_day1_room()

func _load_day1_room():
	var room_data := RoomData.new()
	room_data.room_name = "Waiting Room"
	room_data.reward_money = 2

	var e1 := EnemyData.new()
	e1.enemy_name = "Flu Monster"
	e1.max_hp = 10
	e1.power = 4
	e1.defense = 0

	var e2 := EnemyData.new()
	e2.enemy_name = "Copay Gremlin"
	e2.max_hp = 12
	e2.power = 5
	e2.defense = 1

	room_data.enemies = [e1, e2]

	# IMPORTANT: call an init function on Room (best practice)
	room.init_room(room_data)
