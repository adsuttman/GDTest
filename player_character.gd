extends CharacterBody2D

class_name PlayerCharacter

@export var speed_multiplier: float = 1.0
@export var projectile: PackedScene
@export var projectile_spawn_point: Marker2D
@export var boost_multiplier: float = 1.5
@export var max_energy: int = 100
const MOVE_SPEED: float = 500
var energy: int = max_energy

func _ready() -> void:
	projectile_spawn_point = $ProjectileSpawnPoint


func _physics_process(delta: float) -> void:
	move()
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"): shoot()

func move() -> void:
	var movement: Vector2 = Vector2.ZERO
	var boost = 1
	if Input.is_action_pressed("move_left"): movement.x -= 1.0
	if Input.is_action_pressed("move_right"): movement.x += 1.0
	if Input.is_action_pressed("move_up"): movement.y -= 1.0
	if Input.is_action_pressed("move_down"): movement.y += 1.0
	if (Input.is_action_pressed("boost") && (energy > 0)):
		boost = boost_multiplier
		energy -= 1
	else:
		energy +=1
	velocity = movement * (MOVE_SPEED * speed_multiplier * boost)
	move_and_slide()

func shoot() -> void :
	var inst: Projectile = projectile.instantiate()
	owner.add_child(inst)
	inst.transform = projectile_spawn_point.global_transform
