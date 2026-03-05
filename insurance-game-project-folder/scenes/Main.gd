extends Node

@onready var room: Room = $Room
@export var cursor_texture: Texture2D
@export var cursor_hotspot: Vector2 = Vector2(32, 32)

func _ready():
	if cursor_texture != null:
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, cursor_hotspot)

	GameState.new_game()
	_load_day1_room()

func _load_day1_room():
	var room_data := RoomData.new()
	room_data.room_name = "Waiting Room"
	room_data.reward_money = 2
	room.init_room(room_data)
