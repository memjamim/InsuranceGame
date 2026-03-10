extends CanvasLayer
class_name EndOfDay

signal continued
signal alt_medicine_chosen

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var status_label: Label = $Panel/VBoxContainer/StatusLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var alt_med_button: Button = $Panel/VBoxContainer/AltMedButton

func _ready():
	hide()
	continue_button.pressed.connect(func(): continued.emit())
	alt_med_button.pressed.connect(func(): alt_medicine_chosen.emit())
	alt_med_button.hide()

func show_for_day(day: int, next_status: Dictionary):
	title_label.text = "End of Day %d" % day
	status_label.text = "New condition tomorrow:\n%s\n%s" % [
		next_status.get("name", "Unknown"),
		next_status.get("description", "")
	]
	alt_med_button.visible = GameState.has_completed_first_loop
	show()
