extends CanvasLayer
class_name EndOfDay

signal continued
signal alt_medicine_chosen

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var alt_med_button: Button = $Panel/VBoxContainer/AltMedButton

func _ready():
	hide()
	continue_button.pressed.connect(func(): continued.emit())
	alt_med_button.pressed.connect(func(): alt_medicine_chosen.emit())
	alt_med_button.hide()

func show_for_day(day: int):
	title_label.text = "End of Day %d" % day
	alt_med_button.visible = GameState.has_completed_first_loop
	show()
