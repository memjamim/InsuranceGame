extends Node
class_name Room

@export var enemy_sprite_pool: Array[Texture2D] = []
@export var background_pool: Array[Texture2D] = []
@export var background_rect_path: NodePath = NodePath("Background")

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
	"Associate",
	"Interim",
	"Senior",
	"Assistant Regional",
	"Executive",
	"Provisional",
	"Temporary",
	"Certified",
	"Licensed",
	"Principal",
	"Third Assistant",
	"Junior Vice",
	"Associate Deputy",
	"Second Assistant",
	"Substitute",
	"Adjunct",
	"Visiting",
	"Special",
	"Emergency",
	"Honorary",
	"Unofficial",
	"Probationary",
	"Assistant to the Assistant",
	"Regional",
	"District",
	"Tri-County",
	"Metropolitan",
	"Rural",
	"Continental",
	"Imperial",
	"Grand",
	"Supreme",
	"High",
	"Archon",
	"Exalted",
	"Radiant",
	"Moon-Crowned",
	"Cinder-Blessed",
	"Bone-Seated",
	"Gilded",
	"Thrice-Anointed",
	"God-Emperor's",
	"Rat-King",
	"Storm-Crowned",
	"Iron-Blooded",
	"Ashen",
	"Velvet",
	"Golden",
	"Sainted",
	"Holy",
	"Profane",
	"Unyielding",
	"Eternal",
	"Last",
	"Firstborn",
	"Second Son",
	"Last Daughter",
	"Rat-Like",
	"Many-Handed",
	"Hollow-Eyed",
	"Paper-Crowned",
	"Invoice-Bound",
	"Form-Eating",
	"Seven-Sealed",
	"Twice-Denied",
	"Claim-Burdened",
	"Seal-Bearing",
	"Oath-Bound",
	"Archive-Kept",
	"Window-Seated",
	"Lantern-Fed",
	"Grave-Elected",
	"Vermin-Favored",
	"Quiet",
	"Unspeaking",
	"Unblinking",
	"Red-Handed",
	"White-Gloved",
	"Gold-Toothed",
	"Third-Born",
	"Fourth-Ranked",
	"Ninth-Circle",
	"East Wing",
	"West Annex",
	"North Corridor",
	"South Tower",
	"Keeper of",
	"Warden of",
	"Steward of",
	"Marshal of",
	"Clerk of",
	"Custodian of",
	"Bailiff of",
	"Receiver of",
	"Collector of",
	"Auditor of",
	"Inspector of",
	"Comptroller of",
	"Registrar of",
	"Chancellor of",
	"Khan of",
	"Vizier of",
	"Lord of",
	"Lady of",
	"Master of",
	"Godspeaker of",
	"Voice of",
	"Herald of"
]

@export var suffix_pool: Array[String] = [
	"of Prior Authorization",
	"of the Claims Annex",
	"of Temporary Eligibility",
	"of Recertification",
	"of Endless Appeals",
	"of Missing Documentation",
	"of Incomplete Forms",
	"of Provisional Denial",
	"of Unspecified Billing",
	"of Escalations",
	"of Deferred Review",
	"of the Third Window",
	"of the Fourth Window",
	"of the Fifth Counter",
	"of the Quiet Lobby",
	"of the Last Office",
	"of the Regional Desk",
	"of the Secondary Queue",
	"of the Overflow Department",
	"of Non-Urgent Review",
	"of Manual Processing",
	"of the Long Hold",
	"of the Endless Hold Music",
	"of the Courtesy Callback",
	"of the Pending Reference Number",
	"of the Missing Signature",
	"of the Unreceived Fax",
	"of the Sealed Envelope",
	"of the Duplicate Filing",
	"of the Forgotten Appeal",
	"of the Hollow Moon",
	"of the Copper Throne",
	"of Seven Vermin Courts",
	"of the Drowned Archive",
	"of the Iron Basilica",
	"of the Sable Office",
	"of the Paper Labyrinth",
	"of the Last Lantern",
	"of the Ninth Gate",
	"of Salt and Ash",
	"of the Thousand Stamps",
	"of the Vermin King",
	"of the Rusted Diadem",
	"of the Black Stair",
	"of the Pale Ministry",
	"of the Ashen Court",
	"of the Bone Treasury",
	"of the Red Ledger",
	"of the Blighted Choir",
	"of the Quiet Cathedral",
	"of the Ink Sea",
	"of the Silver Maw",
	"of the Crooked Scepter",
	"of the Dimming Sun",
	"of the Broken Seal",
	"of the Gilded Cage",
	"of the Marble Pit",
	"of the Starved Province",
	"of the Forgotten Province",
	"of the Eastern Office",
	"of the Lower Archive",
	"of the Glass Divider",
	"of the Third Bell",
	"of the Waiting Hall",
	"of the Unlit Corridor",
	"of the Rat Court",
	"of the Candle Tax",
	"of the Rustwater Delta",
	"of the Last Appointment",
	"of the Open Wound",
	"of the Third Scar",
	"of the Seventh Fever",
	"of the Nameless Petition",
	"of the Crimson Registry",
	"of the Department of Missing Forms",
	"of the Office of Prolonged Review",
	"of the Bureau of Delayed Mercy",
	"of the Ministry of Minor Suffering",
	"of the Chamber of Exhausted Breath",
	"of the House of Disputed Coverage",
	"Bearer of Duplicate Paperwork",
	"Keeper of the Unopened Letter",
	"Who Was Denied in Life and Death",
	"Sworn Enemy of Timely Care",
	"Whose Signature Cannot Be Verified",
	"Who Speaks Only in Reference Numbers",
	"Whom No Clerk Will Acknowledge",
	"Patron of Lapsed Coverage",
	"Enemy of the Compassionate Exception",
	"Who Waits Beyond the Glass Divider",
	"Who Dreams in Procedure Codes",
	"Who Files in Triplicate",
	"Who Laughs at Expedited Requests",
	"Whose Name Is Missing from the Record",
	"Whose Hand Is Stamped but Never Seen",
	"Who Sits Beneath Fluorescent Judgment",
	"Who Arrived Before Opening and Never Left",
	"Whose Mercy Is Out of Network"
]

@export var min_enemies_per_encounter: int = 1
@export var max_enemies_per_encounter: int = 4

@export var room_data: RoomData
@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var end_of_day_scene: PackedScene = preload("res://scenes/EndOfDay.tscn")

@export var combat_ui_path: NodePath = NodePath("CombatUI")
@export var enemies_holder_path: NodePath = NodePath("Enemies")

@onready var background_rect: TextureRect = get_node_or_null(background_rect_path) as TextureRect
@onready var combat_ui: CombatUI = get_node_or_null(combat_ui_path) as CombatUI
@onready var enemies_holder: Node = get_node_or_null(enemies_holder_path)

var end_of_day_ui: EndOfDay
var enemies: Array[Enemy] = []
var target_index: int = 0
var initialized: bool = false

func _ready() -> void:
	if room_data == null:
		return
	_init_after_data()

func _unhandled_input(event: InputEvent) -> void:
	if enemies.is_empty() or GameState.in_end_day:
		return

	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		_cycle_target(-1)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		_cycle_target(1)

func init_room(data: RoomData) -> void:
	room_data = data
	_init_after_data()

func _init_after_data() -> void:
	if initialized:
		return
	initialized = true

	if combat_ui == null:
		push_error("Room: CombatUI not found. Check combat_ui_path.")
		return
	if enemies_holder == null:
		push_error("Room: Enemies holder not found. Check enemies_holder_path.")
		return
	if enemy_scene == null:
		push_error("Room: enemy_scene is null.")
		return

	if end_of_day_scene != null:
		end_of_day_ui = end_of_day_scene.instantiate() as EndOfDay
		add_child(end_of_day_ui)
		end_of_day_ui.continued.connect(_on_end_day_continue)
		end_of_day_ui.alt_medicine_chosen.connect(_on_alt_medicine_chosen)

	combat_ui.move_chosen.connect(_on_player_move)

	_spawn_enemies()
	_refresh_ui("Encounter begins.")

func _apply_random_background() -> void:
	if background_rect == null:
		return
	if background_pool.is_empty():
		return

	background_rect.texture = background_pool[randi() % background_pool.size()]

func _spawn_enemies() -> void:
	for c in enemies_holder.get_children():
		c.queue_free()
	enemies.clear()

	_apply_random_background()

	if room_data == null:
		room_data = RoomData.new()
		room_data.room_name = "Waiting Room"
		room_data.reward_money = 2

	var enemy_defs: Array[EnemyData] = _generate_enemy_list_for_encounter()

	for enemy_data in enemy_defs:
		var inst: Enemy = enemy_scene.instantiate() as Enemy
		inst.data = enemy_data
		inst.died.connect(_on_enemy_died)
		inst.selected.connect(_on_enemy_selected)
		enemies_holder.add_child(inst)
		enemies.append(inst)

		if inst.has_method("set_display_index"):
			inst.call("set_display_index", enemies.size() - 1)

	target_index = 0
	_update_enemy_selection_visuals()

func _on_player_move(player_move: int, timing_quality: float) -> void:
	if GameState.in_end_day:
		_set_combat_enabled(false)
		return

	_select_next_valid_target()
	if enemies.is_empty():
		return

	var log_lines: Array[String] = []
	var current_enemies: Array[Enemy] = enemies.duplicate()

	for i in range(current_enemies.size()):
		var enemy: Enemy = current_enemies[i]
		if not is_instance_valid(enemy):
			continue

		var enemy_move: int = enemy.choose_move()
		var outcome: Dictionary

		if i == target_index:
			outcome = CombatResolver.resolve(
				player_move,
				enemy_move,
				GameState.get_modified_player_power(),
				GameState.get_modified_player_defense(),
				enemy.data.power,
				enemy.data.defense + GameState.get_enemy_defense_bonus(),
				timing_quality
			)
		else:
			outcome = CombatResolver.resolve(
				CombatResolver.Move.NONE,
				enemy_move,
				GameState.get_modified_player_power(),
				GameState.get_modified_player_defense(),
				enemy.data.power,
				enemy.data.defense + GameState.get_enemy_defense_bonus(),
				timing_quality
			)

		var player_damage_taken: int = int(outcome.get("player_damage_taken", 0))
		var enemy_damage_taken: int = int(outcome.get("enemy_damage_taken", 0))

		if player_damage_taken > 0:
			GameState.damage_player(player_damage_taken)

		if i == target_index and enemy_damage_taken > 0 and is_instance_valid(enemy):
			enemy.take_damage(enemy_damage_taken)

		var shown_player_move: int = player_move if i == target_index else CombatResolver.Move.NONE
		log_lines.append(_format_combat_line(shown_player_move, enemy_move, outcome, enemy))

	GameState.spend_turn()

	_refresh_ui("\n".join(log_lines))

	if GameState.player_hp <= 0:
		_set_combat_enabled(false)
		return

	if GameState.in_end_day:
		_set_combat_enabled(false)
		if end_of_day_ui != null:
			end_of_day_ui.show_for_day(GameState.day, GameState.get_pending_disease_data())

func _on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)
	_select_next_valid_target()
	_update_enemy_selection_visuals()

	if enemies.is_empty():
		_on_room_cleared()

func _select_next_valid_target() -> void:
	var valid_enemies: Array[Enemy] = []
	for e in enemies:
		if is_instance_valid(e):
			valid_enemies.append(e)
	enemies = valid_enemies

	if enemies.is_empty():
		return

	target_index = clampi(target_index, 0, enemies.size() - 1)

func _cycle_target(dir: int) -> void:
	_select_next_valid_target()
	if enemies.is_empty():
		return

	target_index = wrapi(target_index + dir, 0, enemies.size())
	_update_enemy_selection_visuals()
	_refresh_ui("Target changed to %s." % enemies[target_index].data.base_name)

func _on_enemy_selected(enemy: Enemy) -> void:
	var idx: int = enemies.find(enemy)
	if idx != -1:
		target_index = idx
		_update_enemy_selection_visuals()
		_refresh_ui("Target changed to %s." % enemy.data.base_name)

func _update_enemy_selection_visuals() -> void:
	for i in range(enemies.size()):
		if is_instance_valid(enemies[i]):
			enemies[i].set_selected(i == target_index)

func _on_room_cleared() -> void:
	var heal_amount: int = randi_range(3, 5)
	GameState.heal_player(heal_amount)

	_refresh_ui("Room cleared! You recover %d HP." % heal_amount)

	if not GameState.in_end_day:
		_spawn_enemies()
		_set_combat_enabled(true)
		_refresh_ui("New encounter begins.")

func _on_end_day_continue() -> void:
	GameState.continue_to_next_day()

	if end_of_day_ui != null:
		end_of_day_ui.hide()

	_set_combat_enabled(true)
	_spawn_enemies()
	_refresh_ui("Day %d begins. Diseases: %s" % [
		GameState.day,
		GameState.get_active_disease_summary()
	])

func _on_alt_medicine_chosen() -> void:
	get_tree().change_scene_to_file("res://scenes/endings/AltMedEnding.tscn")

func _set_combat_enabled(enabled: bool) -> void:
	if combat_ui.has_method("set_enabled"):
		combat_ui.call("set_enabled", enabled)
		return

	for b in combat_ui.get_children():
		if b is Button:
			b.disabled = not enabled

func _refresh_ui(message: String) -> void:
	combat_ui.set_log(
		"[Day %d | Turns %d]\nHP: %d/%d \nDiseases: %s\n\n%s\n\nEnemies: %s" % [
			GameState.day,
			GameState.turns_left,
			GameState.player_hp,
			GameState.player_max_hp,
			GameState.get_active_disease_summary(),
			message,
			_enemy_summary()
		]
	)

func _enemy_summary() -> String:
	var parts: Array[String] = []
	for i in range(enemies.size()):
		var e: Enemy = enemies[i]
		if is_instance_valid(e):
			parts.append("%s (%d/%d)" % [e.data.base_name, e.hp, e.data.max_hp])
	return ", ".join(parts)

func _move_name(m: int) -> String:
	match m:
		CombatResolver.Move.ATTACK:
			return "ATTACK"
		CombatResolver.Move.BLOCK:
			return "BLOCK"
		CombatResolver.Move.DODGE:
			return "DODGE"
		CombatResolver.Move.NONE:
			return "WAIT"
		_:
			return "???"

func _format_combat_line(player_move: int, enemy_move: int, outcome: Dictionary, enemy: Enemy) -> String:
	var enemy_name: String = enemy.data.base_name
	var timing_result: String = str(outcome.get("timing_result", "unknown")).to_upper()
	var result: String = str(outcome.get("result", "unknown"))
	var player_damage_taken: int = int(outcome.get("player_damage_taken", 0))
	var enemy_damage_taken: int = int(outcome.get("enemy_damage_taken", 0))

	if enemy_move == CombatResolver.Move.NONE:
		if enemy_damage_taken > 0:
			return "Timing: %s. You played %s. %s hesitated. You hit for %d." % [
				timing_result,
				_move_name(player_move),
				enemy_name,
				enemy_damage_taken
			]
		return "Timing: %s. You played %s. %s hesitated." % [
			timing_result,
			_move_name(player_move),
			enemy_name
		]

	if result == "player_win":
		return "Timing: %s. You played %s. %s played %s. You win and deal %d." % [
			timing_result,
			_move_name(player_move),
			enemy_name,
			_move_name(enemy_move),
			enemy_damage_taken
		]

	if result == "player_miss":
		return "Timing: %s. You played %s. %s played %s. You mistime it and miss." % [
			timing_result,
			_move_name(player_move),
			enemy_name,
			_move_name(enemy_move)
		]

	if result == "enemy_win":
		return "Timing: %s. You played %s. %s played %s. You lose and take %d." % [
			timing_result,
			_move_name(player_move),
			enemy_name,
			_move_name(enemy_move),
			player_damage_taken
		]

	if result == "tie":
		return "Timing: %s. You played %s. %s played %s. Stalemate." % [
			timing_result,
			_move_name(player_move),
			enemy_name,
			_move_name(enemy_move)
		]

	return "Timing: %s. You played %s. %s played %s." % [
		timing_result,
		_move_name(player_move),
		enemy_name,
		_move_name(enemy_move)
	]

func _generate_random_enemy(day_num: int) -> EnemyData:
	var e: EnemyData = EnemyData.new()

	var base: String = _pick_base_enemy_name()
	e.base_name = base
	e.enemy_name = _generate_enemy_name(day_num, base)

	if not enemy_sprite_pool.is_empty():
		e.sprite_texture = enemy_sprite_pool[randi() % enemy_sprite_pool.size()]

	var budget: int = 8 + day_num * 2

	e.max_hp = 6
	e.power = 1
	e.defense = 0

	while budget > 0:
		var pick: int = randi() % 3
		match pick:
			0:
				e.max_hp += 2
			1:
				e.power += 1
			2:
				e.defense += 1
		budget -= 1

	e.weight_attack = 25
	e.weight_block = 25
	e.weight_dodge = 25
	e.weight_wait = 25

	return e

func _pick_base_enemy_name() -> String:
	if not disease_name_pool.is_empty():
		return disease_name_pool[randi() % disease_name_pool.size()]
	return "Disease %d" % randi_range(1, 999)

func _generate_enemy_name(day_num: int, base: String) -> String:
	var prefixes: Array[String] = []
	var suffixes: Array[String] = []

	var cycle_day: int = ((day_num - 1) % 4) + 1
	var tier: int = int((day_num - 1) / 4)

	var prefix_count: int = 0
	var suffix_count: int = 0

	match cycle_day:
		1:
			prefix_count = tier
			suffix_count = tier
		2:
			if randf() < 0.5:
				prefix_count = tier + 1
				suffix_count = tier
			else:
				prefix_count = tier
				suffix_count = tier + 1
		3:
			prefix_count = tier + 1
			suffix_count = tier + 1
		4:
			prefix_count = tier + 1
			suffix_count = tier + 1

	for i in range(prefix_count):
		if not prefix_pool.is_empty():
			prefixes.append(prefix_pool[randi() % prefix_pool.size()])

	for i in range(suffix_count):
		if not suffix_pool.is_empty():
			suffixes.append(suffix_pool[randi() % suffix_pool.size()])

	var full_name: String = ""

	if not prefixes.is_empty():
		full_name += " ".join(prefixes) + " "

	full_name += base

	if not suffixes.is_empty():
		full_name += " " + " ".join(suffixes)

	return full_name

func _generate_enemy_list_for_encounter() -> Array[EnemyData]:
	var list: Array[EnemyData] = []

	var day_num: int = GameState.day
	var min_count: int = 1
	var max_count: int = 2

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

	var count: int = randi_range(min_count, max_count)

	for i in range(count):
		list.append(_generate_random_enemy(day_num))

	return list
