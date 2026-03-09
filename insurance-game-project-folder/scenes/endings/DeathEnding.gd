extends Node
class_name DeathEnding

@onready var panel_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelLabel
@onready var continue_hint: Label       = $MarginContainer/VBoxContainer/ContinueHint

var panels: Array[String] = [
	"[center]As my sickness gets worse, I no longer have the energy to get out of bed.\nMy insurance remains unrenewed. I can’t pay for treatment. I fade.\n\n[/center]",
	"[center]Despite the numerous documents you've collected, you can't get any treatment.\nYou succumed to your disease.\n\n[/center]"
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
