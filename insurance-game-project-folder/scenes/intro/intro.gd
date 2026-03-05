extends Node
class_name Intro

## Scene to load after intro completes. Wire this to your Room or main scene.
@export var next_scene_path: String = "res://scenes/Main.tscn"

@onready var panel_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelLabel
@onready var continue_hint: Label      = $MarginContainer/VBoxContainer/ContinueHint

# Each entry is one screen of text. BBCode supported.
var panels: Array[String] = [
	"[center]It’s been a week since I got sick.\n\nMy doctor says it’s a rare disease that needs to be operated on.\n\nUnfortunately my insurance company says I have to re-register due to a change in policy.\n\n [/center]",

	"[center]I dragged myself out of the house to visit the Department of Insurance Processing.\n\nI just want to get this over with.\n\nThe line is long and I check my documents over and over again, making sure I haven’t forgotten anything.\n\n[/center]",
	
	"[center]“Hello sir. How can I help you today?”\n\n“Hi, I’m here to re-register for my insurance. There was a policy change or something like that. Here are my documents.”\n\n“Right. Please give me a moment to check if you have everything in order.”\n\n [/center]",
	
	"[center]After a moment, the man hands my documents back to me.\n\n“I’m sorry sir, it appears you’re missing some important documents needed for the re-registration.”\n\n“The new policy requires some new documents to be processed.”\n\n“Luckily, the other documents you need can be acquired and filled out in this building.”\n\n“Let’s see. You need forms 27-B/6 though 53-Z/9, registry forms, and some small legal forms that the other staff members can fill you in on.”\n\n[/center]",

	"[center]I could feel my illness flaring up from the stress of this procedure.\n\n“Where do I go to get these forms?”\n\n“Oh you can go up the stairs and someone will help you out.”\n\n“I apologize sir but you are holding up the line so I’m afraid I’ll have to ask you to step out.”\n\n[/center]",

	"[center]I get out of the line and look at the clock on the wall. This office closes at 5 PM.\n\nI don’t have much time to get everything together.\n\nI check my documents, I confirm everything I need to grab, and my fever climbs once again.\n\nI step towards the next floor.\n\n[/center]",

	"[center]\n\n\n[b]DAY 1[/b]\n\n[i]The Lobby[/i]\n\n[color=gray]— Fight the sickness. Collect what you can. —\n[/color][/center]"
]

var _current: int = 0


func _ready() -> void:
	print(panel_label)   # debug: remove once confirmed not null
	print(continue_hint) # debug: remove once confirmed not null
	_show_panel(_current)
	#panel_label.text = "[center]It’s been a week since I got sick.\n\nMy doctor says it’s a rare disease that needs to be operated on.\nUnfortunately my insurance company says I have to re-register due to a change in policy. [/center]"
	#continue_hint.text = "[ Click or press Enter to begin ]"

func _input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
		and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		if _current < panels.size():
			_advance()
		else:
			get_tree().change_scene_to_file(next_scene_path)

func _unhandled_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
		and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		if _current < panels.size():
			_advance()
		else:
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
