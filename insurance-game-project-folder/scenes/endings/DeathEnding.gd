extends Node
class_name DeathEnding

@onready var panel_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelLabel
@onready var continue_hint: Label       = $MarginContainer/VBoxContainer/ContinueHint

var panels: Array[String] = [
	"[center][Bryan Filler Text][/center]",
	"[center][BFT][/center]",
	"[center][BFT0][/center]",
]

var _current: int = 0

func _ready() -> void:
	_show_panel(_current)

func _unhandled_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
		and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		_advance()

func _advance() -> void:
	_current += 1
	if _current >= panels.size():
		get_tree().quit()
		return
	_show_panel(_current)

func _show_panel(index: int) -> void:
	panel_label.text = panels[index]
	continue_hint.text = "[ Press Enter or Click to Let Go ]" \
		if index == panels.size() - 1 \
		else "[ Press Enter or Click to Continue ]"
