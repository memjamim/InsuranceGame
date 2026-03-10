extends Node
class_name Room

@export var enemy_sprite_pool: Array[Texture2D] = []

@export var disease_name_pool: Array[String] = [
	"Claim Gnawer",
	"Form Wraith",
	"Copay Goblin",
	"Denial Beast",
	"Appeals Slime",
	"Premium Leech",
	"Deductible Rat",
	"Coverage Phantom",
	"Billing Horror",
	"Waiting Room Mite"
]

@export var prefix_pool: Array[String] = [
	"Acting",
	"Deputy",
	"Senior",
	"Assistant Regional",
	"Second Interim",
	"Associate Vice",
	"Provisional",
	"Temporary",
	"Certified",
	"Third",
	"Head of the Consulate of Cuba in the",
	"Second Son of the Seventh Day of the School Year"
]

@export var suffix_pool: Array[String] = [
	"of Prior Authorization",
	"of the Claims Annex",
	"of Temporary Authorizations",
	"of Recertification",
	"from the Office of Prolonged Review",
	"of Unspecified Billing",
	"of the Endless Hold Music",
	"of the Department of Missing Forms",
	"Bearer of Duplicate Paperwork",
	"Sworn Enemy of Timely Care"
]

@export var min_enemies_per_encounter: int = 1
@export var max_enemies_per_encounter: int = 4

@export var room_data: RoomData
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var end_of_day_scene: PackedScene = preload("res://scenes/EndOfDay.tscn")

var end_of_day_ui: EndOfDay

@export var combat_ui_path: NodePath = NodePath("CombatUI")
@export var enemies_holder_path: NodePath = NodePath("Enemies")

@onready var combat_ui: CombatUI = get_node_or_null(combat_ui_path) as CombatUI
@onready var enemies_holder: Node = get_node_or_null(enemies_holder_path)

var enemies: Array[Enemy] = []
var target_index: int = 0
var initialized: bool = false

func _ready():
	if room_data == null:
		return
	_init_after_data()

func _unhandled_input(event: InputEvent):
	if enemies.is_empty() or GameState.in_end_day:
		return

	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		_cycle_target(-1)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		_cycle_target(1)

func init_room(data: RoomData) -> void:
	room_data = data
	_init_after_data()

func _init_after_data():
	if initialized:
		return
	initialized = true

	if combat_ui == null:
		push_error("Room: CombatUI not found. Check combat_ui_path.")
		return
	if enemies_holder == null:
		push_error("Room: Enemies holder not found. Check enemies_holder_path.")
		return

	if end_of_day_scene != null:
		end_of_day_ui = end_of_day_scene.instantiate()
		add_child(end_of_day_ui)
		end_of_day_ui.continued.connect(_on_end_day_continue)
		end_of_day_ui.alt_medicine_chosen.connect(_on_alt_medicine_chosen)

	combat_ui.move_chosen.connect(_on_player_move)

	_spawn_enemies()
	_refresh_ui("Encounter begins.")

func _spawn_enemies():
	for c in enemies_holder.get_children():
		c.queue_free()
	enemies.clear()

	if room_data == null:
		room_data = RoomData.new()
		room_data.room_name = "Waiting Room"
		room_data.reward_money = 2

	if enemy_scene == null:
		push_error("Room: enemy_scene is null. Check the exported PackedScene or preload path.")
		return

	var enemy_defs := _generate_enemy_list_for_encounter()

	for enemy_data in enemy_defs:
		var inst: Enemy = enemy_scene.instantiate()
		inst.data = enemy_data
		inst.died.connect(_on_enemy_died)
		inst.selected.connect(_on_enemy_selected)
		enemies_holder.add_child(inst)
		enemies.append(inst)

	target_index = 0
	_update_enemy_selection_visuals()

func _on_player_move(player_move: int, timing_quality: float):
	if GameState.in_end_day:
		_set_combat_enabled(false)
		return

	_select_next_valid_target()
	if enemies.is_empty():
		return

	var target := enemies[target_index]
	var enemy_move := target.choose_move()

	var outcome := CombatResolver.resolve(
		player_move,
		enemy_move,
		GameState.get_modified_player_power(),
		GameState.get_modified_player_defense(),
		target.data.power,
		target.data.defense + GameState.get_enemy_defense_bonus(),
		timing_quality
	)

	if outcome["player_damage_taken"] > 0:
		GameState.damage_player(outcome["player_damage_taken"])
	if outcome["enemy_damage_taken"] > 0:
		target.take_damage(outcome["enemy_damage_taken"])

	GameState.spend_turn()

	var log_text := _format_log(player_move, enemy_move, outcome, target)
	_refresh_ui(log_text)

	if GameState.player_hp <= 0:
		_refresh_ui("You collapse.")
		_set_combat_enabled(false)
		return

	if GameState.in_end_day:
		_set_combat_enabled(false)
		if end_of_day_ui != null:
			var preview_status := _roll_preview_status()
			end_of_day_ui.show_for_day(GameState.day, GameState.get_pending_status_data())

func _on_enemy_died(enemy: Enemy):
	enemies.erase(enemy)
	_select_next_valid_target()
	_update_enemy_selection_visuals()

	if enemies.is_empty():
		_on_room_cleared()

func _select_next_valid_target():
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	if enemies.is_empty():
		return
	target_index = clampi(target_index, 0, enemies.size() - 1)

func _cycle_target(dir: int):
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	if enemies.is_empty():
		return

	target_index = wrapi(target_index + dir, 0, enemies.size())
	_update_enemy_selection_visuals()
	_refresh_ui("Target changed to %s." % enemies[target_index].data.enemy_name)

func _on_enemy_selected(enemy: Enemy):
	var idx := enemies.find(enemy)
	if idx != -1:
		target_index = idx
		_update_enemy_selection_visuals()
		_refresh_ui("Target changed to %s." % enemy.data.enemy_name)

func _update_enemy_selection_visuals():
	for i in range(enemies.size()):
		if is_instance_valid(enemies[i]):
			enemies[i].set_selected(i == target_index)

func _on_room_cleared():
	GameState.money += room_data.reward_money

	_refresh_ui("Room cleared! +%d money." % room_data.reward_money)

	if not GameState.in_end_day:
		_spawn_enemies()
		_set_combat_enabled(true)
		_refresh_ui("New encounter begins.")

func _on_end_day_continue():
	GameState.continue_to_next_day()

	if end_of_day_ui != null:
		end_of_day_ui.hide()

	_set_combat_enabled(true)
	_spawn_enemies()
	_refresh_ui("Day %d begins. Status: %s" % [
		GameState.day,
		GameState.get_status_data().get("name", "None")
	])

func _set_combat_enabled(enabled: bool):
	if combat_ui.has_method("set_enabled"):
		combat_ui.call("set_enabled", enabled)
		return

	for b in combat_ui.get_children():
		if b is Button:
			b.disabled = not enabled

func _refresh_ui(message: String):
	var status := GameState.get_status_data()
	combat_ui.set_log(
		"[Day %d | Turns %d]\nHP: %d/%d | Money: %d\nStatus: %s\n\n%s\n\nEnemies: %s" % [
			GameState.day,
			GameState.turns_left,
			GameState.player_hp,
			GameState.player_max_hp,
			GameState.money,
			status.get("name", "None"),
			message,
			_enemy_summary()
		]
	)

func _enemy_summary() -> String:
	var parts: Array[String] = []
	for i in range(enemies.size()):
		var e := enemies[i]
		if is_instance_valid(e):
			var tag := ""
			if i == target_index:
				tag = " [TARGET]"
			parts.append("%s (%d/%d)%s" % [e.data.enemy_name, e.hp, e.data.max_hp, tag])
	return ", ".join(parts)

func _format_log(player_move: int, enemy_move: int, outcome: Dictionary, target: Enemy) -> String:
	return "You: %s | %s: %s\nResult: %s\nYou take %d, Enemy takes %d" % [
		_move_name(player_move),
		target.data.enemy_name,
		_move_name(enemy_move),
		outcome["result"],
		outcome["player_damage_taken"],
		outcome["enemy_damage_taken"]
	]

func _move_name(m: int) -> String:
	match m:
		CombatResolver.Move.ATTACK: return "ATTACK"
		CombatResolver.Move.BLOCK: return "BLOCK"
		CombatResolver.Move.DODGE: return "DODGE"
		_: return "???"

func _generate_random_enemy(day_num: int) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_name = _generate_enemy_name(day_num)

	if not enemy_sprite_pool.is_empty():
		e.sprite_texture = enemy_sprite_pool[randi() % enemy_sprite_pool.size()]

	var budget := 8 + day_num * 2
	e.max_hp = 6
	e.power = 1
	e.defense = 0

	while budget > 0:
		var pick := randi() % 3
		match pick:
			0:
				e.max_hp += 2
			1:
				e.power += 1
			2:
				e.defense += 1
		budget -= 1

	e.weight_attack = randi_range(25, 60)
	e.weight_block = randi_range(10, 40)
	e.weight_dodge = randi_range(10, 40)

	return e

func _generate_enemy_name(day_num: int) -> String:
	var base := "Disease %d" % randi_range(1, 999)
	if not disease_name_pool.is_empty():
		base = disease_name_pool[randi() % disease_name_pool.size()]

	var prefix_count: int = mini(3, day_num / 3)
	var suffix_count: int = mini(3, day_num / 4)

	var prefixes: Array[String] = []
	var suffixes: Array[String] = []

	for i in range(prefix_count):
		if not prefix_pool.is_empty():
			prefixes.append(prefix_pool[randi() % prefix_pool.size()])

	for i in range(suffix_count):
		if not suffix_pool.is_empty():
			suffixes.append(suffix_pool[randi() % suffix_pool.size()])

	var full_name := ""
	if not prefixes.is_empty():
		full_name += " ".join(prefixes) + " "
	full_name += base
	if not suffixes.is_empty():
		full_name += " " + " ".join(suffixes)

	return full_name

func _generate_enemy_list_for_encounter() -> Array[EnemyData]:
	var list: Array[EnemyData] = []

	var day_num := GameState.day
	var min_count := 1
	var max_count := 2

	if day_num >= 2:
		max_count = 3
	if day_num >= 3:
		min_count = 2
		max_count = 4
	if day_num >= 6:
		min_count = 3
		max_count = 4

	min_count = clampi(min_count, min_enemies_per_encounter, max_enemies_per_encounter)
	max_count = clampi(max_count, min_count, max_enemies_per_encounter)

	var count := randi_range(min_count, max_count)

	for i in range(count):
		list.append(_generate_random_enemy(day_num))

	return list

func _roll_preview_status() -> Dictionary:
	# Shortcut for the end-day UI to preview what next day will apply.
	# For now just show the currently configured getter or change to a pending-status system.
	return GameState.get_status_data()

func _on_alt_medicine_chosen() -> void:
	get_tree().change_scene_to_file("res://scenes/endings/AltMedEnding.tscn")
