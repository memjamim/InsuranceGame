extends Node
class_name Intro

## Scene to load after intro completes. Wire this to your Room or main scene.
@export var next_scene_path: String = "res://scenes/Main.tscn"

@onready var panel_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelLabel
@onready var continue_hint: Label      = $MarginContainer/VBoxContainer/ContinueHint

# Each entry is one screen of text. BBCode supported.
var panels: Array[String] = [
	"[center]You have been sick for three weeks.\n\nYour doctor says you need a procedure.\nYour insurance company says you need pre-authorization.\n\nPre-authorization requires [b]Form 27-B/6[/b].\nForm 27-B/6 is only available at the\n[b]Department of Insurance Processing, Level 4.[/b]\n\nLevel 4 requires a visitor badge.\nVisitor badges are issued at the front desk.[/center]",

	"[center]Today, you will go to the front desk.\n\nYou carry what little money you have.\nYou carry the vague hope that today someone will help you.\n\nThe building closes at 5 PM.\n\n[i]You have been telling yourself this for three weeks.[/i][/center]",

	"[center]\n\n\n[b]DAY 1[/b]\n\n[i]The Lobby[/i]\n\n[color=gray]— Fight through to the front desk. Collect what you can. —[/color][/center]"
]

var _current: int = 0


func _ready() -> void:
	print(panel_label)   # debug: remove once confirmed not null
	print(continue_hint) # debug: remove once confirmed not null
	panel_label.text = "[center]You have been sick for three weeks.\n\nYour doctor says you need a procedure.\nYour insurance company says you need pre-authorization.\n\nPre-authorization requires [b]Form 27-B/6[/b].\nForm 27-B/6 is only available at the\n[b]Department of Insurance Processing, Level 4.[/b]\n\nLevel 4 requires a visitor badge.\nVisitor badges are issued at the front desk.\n\n[i]You have been telling yourself this for three weeks.[/i][/center]"
	continue_hint.text = "[ Click or press Enter to begin ]"

func _input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
		and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		get_tree().change_scene_to_file(next_scene_path)

func _unhandled_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
		and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		get_tree().change_scene_to_file(next_scene_path)


func _advance() -> void:
	_current += 1
	if _current >= panels.size():
		get_tree().change_scene_to_file(next_scene_path)
		return
	_show_panel(_current)

func _show_panel(index: int) -> void:
	panel_label.text = panels[index]
	if index == panels.size() - 1:
		continue_hint.text = "[ Press Enter or Click to Begin ]"
	else:
		continue_hint.text = "[ Press Enter or Click to Continue ]"
