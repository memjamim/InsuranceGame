extends CanvasLayer
class_name EndOfDay

signal continued

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton

func _ready():
	hide()
	continue_button.pressed.connect(func(): continued.emit())

func show_for_day(day: int):
	title_label.text = "End of Day %d" % day
	show()
