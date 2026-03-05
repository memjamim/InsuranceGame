extends Control
class_name CombatUI

signal move_chosen(move: int, timing_quality: float)

@onready var log_label: Label = $LogLabel
@onready var attack_btn: Button = $HBoxContainer/AttackButton
@onready var block_btn: Button  = $HBoxContainer/BlockButton
@onready var dodge_btn: Button  = $HBoxContainer/DodgeButton

@onready var timing_bar: Control = $TimingBar
@onready var sweet_spot: Control = $TimingBar/SweetSpot
@onready var marker: Control = $TimingBar/Marker
@onready var timing_button: Button = $TimingButton

var timing_active: bool = false
var selected_move: int = CombatResolver.Move.ATTACK
var marker_t: float = 0.0
var marker_dir: float = 1.0
var timing_speed: float = 1.8

func _ready():
	attack_btn.pressed.connect(func(): _begin_timing(CombatResolver.Move.ATTACK))
	block_btn.pressed.connect(func(): _begin_timing(CombatResolver.Move.BLOCK))
	dodge_btn.pressed.connect(func(): _begin_timing(CombatResolver.Move.DODGE))
	timing_button.pressed.connect(_commit_timing)

	timing_bar.hide()
	timing_button.hide()

func _process(delta: float):
	if not timing_active:
		return

	marker_t += marker_dir * timing_speed * delta
	if marker_t >= 1.0:
		marker_t = 1.0
		marker_dir = -1.0
	elif marker_t <= 0.0:
		marker_t = 0.0
		marker_dir = 1.0

	var usable_width: float = timing_bar.size.x - marker.size.x
	marker.position.x = marker_t * max(0.0, usable_width)

func _begin_timing(move: int):
	if timing_active:
		return

	selected_move = move
	timing_active = true
	marker_t = 0.0
	marker_dir = 1.0

	attack_btn.disabled = true
	block_btn.disabled = true
	dodge_btn.disabled = true

	timing_bar.show()
	timing_button.show()

func _commit_timing():
	if not timing_active:
		return

	timing_active = false

	var quality := _calculate_timing_quality()

	timing_bar.hide()
	timing_button.hide()

	attack_btn.disabled = false
	block_btn.disabled = false
	dodge_btn.disabled = false

	move_chosen.emit(selected_move, quality)

func _calculate_timing_quality() -> float:
	var marker_center: float = marker.global_position.x + marker.size.x * 0.5
	var sweet_center: float = sweet_spot.global_position.x + sweet_spot.size.x * 0.5
	var max_dist: float = maxf(1.0, timing_bar.size.x * 0.5)

	var dist: float = absf(marker_center - sweet_center)
	var q: float = 1.0 - (dist / max_dist)
	return clampf(q, 0.0, 1.0)

func set_log(text: String):
	log_label.text = text

func set_enabled(enabled: bool):
	attack_btn.disabled = not enabled
	block_btn.disabled = not enabled
	dodge_btn.disabled = not enabled

	if not enabled:
		timing_active = false
		timing_bar.hide()
		timing_button.hide()
