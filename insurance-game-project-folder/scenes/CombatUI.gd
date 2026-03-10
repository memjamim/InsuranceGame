extends Control
class_name CombatUI

signal move_chosen(move: int, timing_quality: float)

@onready var log_label: Label = $LogLabel
@onready var attack_btn: Button = $HBoxContainer/AttackButton
@onready var block_btn: Button = $HBoxContainer/BlockButton
@onready var dodge_btn: Button = $HBoxContainer/DodgeButton

@onready var timing_bar: Control = $TimingBar
@onready var sweet_spot: Control = $TimingBar/SweetSpot
@onready var marker: Control = $TimingBar/Marker
@onready var timing_button: Button = $TimingButton

@onready var perfect_spot: Control = $TimingBar/SweetSpot/PerfectSpot if has_node("TimingBar/SweetSpot/PerfectSpot") else null

var timing_active: bool = false
var selected_move: int = CombatResolver.Move.ATTACK
var marker_t: float = 0.0
var marker_dir: float = 1.0

var base_timing_speed: float = 1.8
var base_sweet_spot_width: float = 80.0
var base_perfect_spot_width: float = 16.0
var marker_width: float = 12.0

func _ready() -> void:
	attack_btn.pressed.connect(func(): _begin_timing(CombatResolver.Move.ATTACK))
	block_btn.pressed.connect(func(): _begin_timing(CombatResolver.Move.BLOCK))
	dodge_btn.pressed.connect(func(): _begin_timing(CombatResolver.Move.DODGE))
	timing_button.pressed.connect(_commit_timing)

	# Defensive setup in case the scene was configured oddly.
	marker.set_anchors_preset(Control.PRESET_TOP_LEFT)
	marker.custom_minimum_size = Vector2(marker_width, timing_bar.size.y)
	marker.size = Vector2(marker_width, timing_bar.size.y)
	marker.position = Vector2.ZERO

	sweet_spot.set_anchors_preset(Control.PRESET_TOP_LEFT)

	if perfect_spot != null:
		perfect_spot.set_anchors_preset(Control.PRESET_TOP_LEFT)

	timing_bar.hide()
	timing_button.hide()

	set_enabled(true)

func _process(delta: float) -> void:
	if not timing_active:
		return

	var actual_speed: float = base_timing_speed * GameState.get_timing_speed_multiplier()

	marker_t += marker_dir * actual_speed * delta

	if marker_t >= 1.0:
		marker_t = 1.0
		marker_dir = -1.0
	elif marker_t <= 0.0:
		marker_t = 0.0
		marker_dir = 1.0

	var usable_width: float = timing_bar.size.x - marker.size.x
	marker.position.x = marker_t * maxf(0.0, usable_width)

func _unhandled_input(event: InputEvent) -> void:
	if not timing_active:
		return

	if event.is_action_pressed("ui_accept"):
		_commit_timing()
		accept_event()

func _begin_timing(move: int) -> void:
	if timing_active:
		return

	selected_move = move
	timing_active = true
	marker_t = 0.0
	marker_dir = 1.0

	_configure_timing_bar()

	marker.position = Vector2.ZERO

	attack_btn.disabled = true
	block_btn.disabled = true
	dodge_btn.disabled = true

	timing_bar.show()
	timing_button.show()

func _commit_timing() -> void:
	if not timing_active:
		return

	timing_active = false

	var quality: float = _calculate_timing_quality()

	timing_bar.hide()
	timing_button.hide()

	set_enabled(true)

	move_chosen.emit(selected_move, quality)

func _configure_timing_bar() -> void:
	var width_mult: float = GameState.get_timing_sweet_spot_multiplier()
	var new_width: float = base_sweet_spot_width * width_mult

	sweet_spot.size.x = new_width
	sweet_spot.size.y = timing_bar.size.y
	sweet_spot.position.x = (timing_bar.size.x - new_width) * 0.5
	sweet_spot.position.y = 0.0

	marker.size.x = marker_width
	marker.size.y = timing_bar.size.y

	if perfect_spot != null:
		perfect_spot.size.x = minf(base_perfect_spot_width, sweet_spot.size.x)
		perfect_spot.size.y = sweet_spot.size.y
		perfect_spot.position.x = (sweet_spot.size.x - perfect_spot.size.x) * 0.5
		perfect_spot.position.y = 0.0

func _calculate_timing_quality() -> float:
	var marker_center: float = marker.position.x + marker.size.x * 0.5
	var sweet_left: float = sweet_spot.position.x
	var sweet_right: float = sweet_spot.position.x + sweet_spot.size.x

	# Inside sweet spot = strong score, closer to center = better.
	if marker_center >= sweet_left and marker_center <= sweet_right:
		var sweet_center: float = sweet_spot.position.x + sweet_spot.size.x * 0.5
		var dist_from_center: float = absf(marker_center - sweet_center)
		var max_center_dist: float = maxf(1.0, sweet_spot.size.x * 0.5)
		var centered_quality: float = 1.0 - (dist_from_center / max_center_dist)

		# Map inside-sweet-spot results into 0.85..1.0
		return clampf(0.85 + centered_quality * 0.15, 0.0, 1.0)

	# Outside sweet spot: fall off down toward miss.
	var dist_to_zone: float = 0.0
	if marker_center < sweet_left:
		dist_to_zone = sweet_left - marker_center
	else:
		dist_to_zone = marker_center - sweet_right

	var falloff_range: float = maxf(1.0, timing_bar.size.x * 0.35)
	var outside_quality: float = 0.85 * (1.0 - (dist_to_zone / falloff_range))
	return clampf(outside_quality, 0.0, 0.84)

func set_log(text: String) -> void:
	log_label.text = text

func set_enabled(enabled: bool) -> void:
	var disabled_move: int = GameState.get_disabled_move()

	attack_btn.disabled = not enabled or disabled_move == CombatResolver.Move.ATTACK
	block_btn.disabled = not enabled or disabled_move == CombatResolver.Move.BLOCK
	dodge_btn.disabled = not enabled or disabled_move == CombatResolver.Move.DODGE

	if not enabled:
		timing_active = false
		timing_bar.hide()
		timing_button.hide()
