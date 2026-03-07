extends Node

@onready var room: Room = $Room
@export var cursor_texture: Texture2D
@export var cursor_hotspot: Vector2 = Vector2(32, 32)

func _ready():
	if cursor_texture != null:
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, cursor_hotspot)
	
	GameState.player_died.connect(_on_player_died)
	GameState.new_game()
	_load_day1_room()

func _load_day1_room():
	var room_data := RoomData.new()
	room_data.room_name = "Waiting Room"
	room_data.reward_money = 2
	room.init_room(room_data)

func _on_player_died() -> void:
	_fade_then_load("res://scenes/endings/DeathEnding.tscn")

func _fade_then_load(target_scene: String) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 1.2)
	await tween.finished
	get_tree().change_scene_to_file(target_scene)

# Todo: Make # of enemies scale with room # for day / total, make enemies selectable, make timing system work properly / give it a hotkey, do rewards after each fight.
