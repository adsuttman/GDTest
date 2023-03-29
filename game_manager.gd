extends Node

@onready var enemy_scene: PackedScene = load("res://enemy.tscn")
#@onready var player_scene: PackedScene = load("res://player_character.tscn")
var wave: int = 1
var enemies_remaining: int = 1
var spawn_count: int = 1
var spawn_points: Array = []
var level: Node2D
var spawn_timer: Timer
var time_between_spawns: float = 1.0
var player: PlayerCharacter
var score: int = 0

signal score_updated(score: int)

func _ready():
	var tree = get_tree()
	level = tree.get_first_node_in_group("Level")
	spawn_points = tree.get_nodes_in_group("SpawnPoint")
	player = tree.get_first_node_in_group("Player")
	initialize_spawn_timer()
	player.player_death.connect(handle_player_death)
	

func initialize_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = time_between_spawns
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn_enemy)

func spawn_enemy() -> void:
	var random_spawn: Node2D = \
		spawn_points[randi_range(0, spawn_points.size() - 1)] as Node2D
#	print(random_spawn)
	var inst: Enemy = enemy_scene.instantiate()
	inst.global_position = random_spawn.global_position
	level.add_child(inst)
	inst.enemy_death.connect(handle_enemy_death)

func increase_score() -> void:
	score += 1
	score_updated.emit(score)

func handle_player_death() -> void:
	spawn_timer.stop()

func handle_enemy_death() -> void:
	increase_score()
