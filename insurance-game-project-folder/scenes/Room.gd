extends Node
class_name Room

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

func init_room(data: RoomData) -> void:
	room_data = data
	_init_after_data()

func _init_after_data():
	if initialized:
		return
	initialized = true

	# Safety checks
	if combat_ui == null:
		push_error("Room: CombatUI not found. Check combat_ui_path.")
		return
	if enemies_holder == null:
		push_error("Room: Enemies holder not found. Check enemies_holder_path.")
		return

	# End-of-day overlay
	if end_of_day_scene != null:
		end_of_day_ui = end_of_day_scene.instantiate()
		add_child(end_of_day_ui)
		end_of_day_ui.continued.connect(_on_end_day_continue)

	combat_ui.move_chosen.connect(_on_player_move)

	_spawn_enemies()
	_refresh_ui("Encounter begins.")

func _spawn_enemies():
	# Clear existing encounter if any
	for c in enemies_holder.get_children():
		c.queue_free()
	enemies.clear()

	if room_data == null:
		push_warning("Room has no RoomData; creating default with 1 enemy.")
		room_data = RoomData.new()
		var e := EnemyData.new()
		e.enemy_name = "Paperwork Wraith"
		room_data.enemies = [e]

	for enemy_data in room_data.enemies:
		var inst: Enemy = enemy_scene.instantiate()
		inst.data = enemy_data
		inst.died.connect(_on_enemy_died)
		enemies_holder.add_child(inst) # GridContainer
		enemies.append(inst)

	target_index = 0

func _on_player_move(player_move: int):
	# If the day is over, ignore inputs
	if GameState.in_end_day:
		_set_combat_enabled(false)
		return

	if enemies.is_empty():
		return

	_select_next_valid_target()
	if enemies.is_empty():
		return

	var target := enemies[target_index]
	var enemy_move := target.choose_move()

	var outcome := CombatResolver.resolve(
		player_move, enemy_move,
		GameState.player_power, GameState.player_defense,
		target.data.power, target.data.defense
	)

	if outcome["player_damage_taken"] > 0:
		GameState.damage_player(outcome["player_damage_taken"])
	if outcome["enemy_damage_taken"] > 0:
		target.take_damage(outcome["enemy_damage_taken"])

	# Spend 1 turn per player action
	GameState.spend_turn()

	var log_text := _format_log(player_move, enemy_move, outcome, target)
	_refresh_ui(log_text)

	# Player death hook
	if GameState.player_hp <= 0:
		_refresh_ui("You collapse. (Game over hook goes here.)")
		_set_combat_enabled(false)
		return

	# End-of-day hook
	if GameState.in_end_day:
		_set_combat_enabled(false)
		if end_of_day_ui != null:
			end_of_day_ui.show_for_day(GameState.day)

func _on_enemy_died(enemy: Enemy):
	enemies.erase(enemy)
	_select_next_valid_target()

	if enemies.is_empty():
		_on_room_cleared()

func _select_next_valid_target():
	# remove invalid refs if any (just in case)
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	if enemies.is_empty():
		return
	target_index = clampi(target_index, 0, enemies.size() - 1)

func _on_room_cleared():
	# Rewards only. Turns are spent per move now.
	GameState.money += room_data.reward_money

	_refresh_ui("Room cleared! +%d money.\n(Next room selection later.)" % room_data.reward_money)

	# For now: immediately start another encounter using same room_data
	# If the day ended exactly on the last move, don't restart until continue.
	if not GameState.in_end_day:
		_spawn_enemies()
		_set_combat_enabled(true)
		_refresh_ui("New encounter begins.")

func _on_end_day_continue():
	# Advance day + reset turns
	GameState.continue_to_next_day()

	# Hide overlay and start fresh encounter
	if end_of_day_ui != null:
		end_of_day_ui.hide()

	_set_combat_enabled(true)
	_spawn_enemies()
	_refresh_ui("Day %d begins." % GameState.day)

func _set_combat_enabled(enabled: bool):
	# Preferred: CombatUI provides set_enabled()
	if combat_ui.has_method("set_enabled"):
		combat_ui.call("set_enabled", enabled)
		return

	# Fallback: disable any Buttons under CombatUI
	for b in combat_ui.get_children():
		if b is Button:
			b.disabled = not enabled

func _refresh_ui(message: String):
	combat_ui.set_log(
		"[Day %d | Turns %d]\nHP: %d/%d | Money: %d\n\n%s\n\nEnemies: %s" % [
			GameState.day,
			GameState.turns_left,
			GameState.player_hp,
			GameState.player_max_hp,
			GameState.money,
			message,
			_enemy_summary()
		]
	)

func _enemy_summary() -> String:
	var parts: Array[String] = []
	for e in enemies:
		if is_instance_valid(e):
			parts.append("%s (%d/%d)" % [e.data.enemy_name, e.hp, e.data.max_hp])
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
