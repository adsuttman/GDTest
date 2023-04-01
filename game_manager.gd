extends Node

@onready var enemy_scene: PackedScene = load("res://enemy.tscn")
@onready var player_scene: PackedScene = load("res://player_character.tscn")
var wave: int
var enemies_remaining: int
var spawn_count: int
var spawn_points: Array = []
var level: Node2D
var spawn_timer: Timer
var time_between_spawns: float = 1.0
var player: PlayerCharacter
var score: int
var last_spawn_index = 0
var restart_counter = 60

signal score_updated(score: int)
signal new_wave(wave: int)
signal restarted(new_player: PlayerCharacter)

func _ready():
	var tree = get_tree()
	level = tree.get_first_node_in_group("Level")
	spawn_points = tree.get_nodes_in_group("SpawnPoint")
	process_mode = Node.PROCESS_MODE_ALWAYS
	start()


func instantiate_player():
	player = player_scene.instantiate()
	player.player_death.connect(handle_player_death)
	player.position.x = 640
	player.position.y = 360
	level.add_child(player)

func initialize_spawn_timer() -> void:
	if spawn_timer != null:
		spawn_timer.queue_free()
	spawn_timer = Timer.new()
	spawn_timer.wait_time = time_between_spawns
	spawn_timer.autostart = true
	spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_enemy)

func start():
	instantiate_player()
	wave = 1
	spawn_count = 0
	score = 0
	enemies_remaining = calculate_enemies(wave)
#	score_updated.emit(score)
#	new_wave.emit(wave)
	initialize_spawn_timer()

func restart():
	restart_counter = 60
	var tree = get_tree()
	for enemy in tree.get_nodes_in_group("Enemy"):
		enemy.queue_free()
	for projectile in tree.get_nodes_in_group("Projectile"):
		projectile.queue_free()
	if player != null:
		player.queue_free()
	start()
	restarted.emit(player)

func _process(delta):
	if Input.is_action_pressed("restart"):
		if restart_counter == 0:
			restart()
		else:
			restart_counter -= 1
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

func spawn_enemy() -> void:
	var random_spawn: Node2D
	while (true):
		var index: int = randi_range(0, spawn_points.size() - 1)
		if index != last_spawn_index:
			random_spawn = spawn_points[index] as Node2D
			last_spawn_index = index
			break
#	print(random_spawn)
	var inst: Enemy = enemy_scene.instantiate()
	inst.global_position = random_spawn.global_position
	level.add_child(inst)
	inst.enemy_death.connect(handle_enemy_death)
	spawn_count += 1
	if spawn_count == calculate_enemies(wave):
		spawn_timer.stop()

func calculate_enemies(wave: int) -> int:
	return wave * 2

func increase_score() -> void:
	score += 1
	score_updated.emit(score)

func handle_next_wave() ->void:
	spawn_count = 0
	wave += 1
	enemies_remaining = calculate_enemies(wave)
	spawn_timer.start()
	new_wave.emit(wave)

func handle_player_death() -> void:
	spawn_timer.stop()

func handle_enemy_death() -> void:
	enemies_remaining -= 1
	increase_score()
	if enemies_remaining == 0:
		handle_next_wave()
