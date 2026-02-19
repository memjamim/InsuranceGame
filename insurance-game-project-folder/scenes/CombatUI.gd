extends Control
class_name CombatUI

signal move_chosen(move: int)

@onready var log_label: Label = $LogLabel
@onready var attack_btn: Button = $HBoxContainer/AttackButton
@onready var block_btn: Button  = $HBoxContainer/BlockButton
@onready var dodge_btn: Button  = $HBoxContainer/DodgeButton

func _ready():
	attack_btn.pressed.connect(func(): move_chosen.emit(CombatResolver.Move.ATTACK))
	block_btn.pressed.connect(func(): move_chosen.emit(CombatResolver.Move.BLOCK))
	dodge_btn.pressed.connect(func(): move_chosen.emit(CombatResolver.Move.DODGE))

func set_log(text: String):
	log_label.text = text

func set_enabled(enabled: bool):
	attack_btn.disabled = not enabled
	block_btn.disabled = not enabled
	dodge_btn.disabled = not enabled
