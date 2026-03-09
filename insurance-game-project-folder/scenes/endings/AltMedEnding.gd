extends Node
class_name AltMedEnding

@onready var panel_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelLabel
@onready var continue_hint: Label       = $MarginContainer/VBoxContainer/ContinueHint

var panels: Array[String] = [
	"[center]I’ve been trying to get my insurance renewed for days now.\nThe torrent of paperwork is neverending and there seems to be no way forward.\n\n[/center]",
	"[center]My sickness has been getting worse over the past couple days.\n\nI’m hitting my limit.\n\nIn my desperation, I began searching for anything, anything that could alleviate my sickness.\n\n[/center]",
	"[center]I search through untested treatments, shady drugs, and various other dubious options.\nAll of it’s either too expensive or looks like it’ll kill me. Just as I was losing hope, I spotted something.\nIt’s simply called a Get Better Pill. It claims to alleviate sickness and pain for a reasonable price.\nI can’t shake how suspicious this pill is but it’s my only option. Before I can talk myself out of it, I order a box of the Get Better Pill.\n\n[/center]",
	"[center]When the box of pills arrived the following day, I didn’t hesitate to take them.\nI needed something to help manage my sickness. To my immense relief, I woke up the following day feeling markedly better.\nWhile I still felt under the weather, the agonizing worst of the symptoms had mercifully passed.\nWith renewed hope, I continue taking the Get Better Pills.\n\n[/center]",
	"[center]The pills began losing their effectiveness soon after I started taking them.\nThe agonizing symptoms that passed crawled their way back to torment me. I was desperate for the relief the pills provided so I began my research.\nAccording to some forums I found, the Get Better Pills can be made more effective through auxiliary products.\n\n[/center]",
	"[center]My room transformed over the next couple days.\nThe smell of aromatic oils linger in the air, sticking to everything in the room. Warm crystals hang over by bed.\nIt's been transformed into a den for healing me. I lay in bed. I’m tired.\n\n[/center]",
	"[center]It’s not long before I run out of money.\nWithout any means of supporting myself, I succumb to my disease.\n\nWhat an unfortunate turn of events.\n\n[/center]"
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
	continue_hint.text = "[ Press Enter or Click to Find Nirvanna ]" \
		if index == panels.size() - 1 \
		else "[ Press Enter or Click to Continue ]"
