extends CharacterBody2D

class_name PlayerCharacter

@export var speed_multiplier: float = 1.0
@export var projectile: PackedScene
@export var projectile_spawn_point: Marker2D
@export var boost_multiplier: float = 2.0
@export var max_energy: int = 100
@export var shoot_effect: PackedScene
@onready var level = get_tree().get_first_node_in_group("Level")
var acceleration = 1500
var friction = 1000
const MOVE_SPEED: float = 500
var energy: int
var dead = false

signal energy_changed(value: int)
signal player_death()

func _ready() -> void:
	set_energy(max_energy)
	projectile_spawn_point = $ProjectileSpawnPoint

func _physics_process(delta: float) -> void:
	if !dead:
		move(delta)
		look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("shoot") and energy > 0: shoot()

func move(delta) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var max_speed = MOVE_SPEED
	if input_direction.length() > 0:
		if Input.is_action_pressed("boost") && energy > 0:
			velocity += input_direction * acceleration * boost_multiplier * delta
			set_energy(energy - 1)
			velocity = velocity.limit_length(max_speed * boost_multiplier)
		else:
			velocity += input_direction * acceleration * delta
			set_energy(energy + 1)
			velocity = velocity.limit_length(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
#	print(velocity)
	move_and_slide()

#func move() -> void:
#	var movement: Vector2 = Vector2.ZERO
#	var boost = 1
##	print(energy)
#	if Input.is_action_pressed("move_left"): movement.x -= 1.0
#	if Input.is_action_pressed("move_right"): movement.x += 1.0
#	if Input.is_action_pressed("move_up"): movement.y -= 1.0
#	if Input.is_action_pressed("move_down"): movement.y += 1.0
#	if Input.is_action_pressed("boost"):
#		if energy > 0:
##			print("boosting...")
#			boost = boost_multiplier
#			set_energy(energy - 1)
#		else:
##			print("out of energy!")
#			pass
#	else:
##		print("Regenerating energy...")
#		set_energy(energy + 1)
#	velocity = movement.normalized() * (MOVE_SPEED * speed_multiplier * boost)
##	print(velocity)
#	move_and_slide()

func shoot() -> void :
	var inst: Projectile = projectile.instantiate()
	inst.spawned_from = self
	level.add_child(inst)
	inst.transform = projectile_spawn_point.global_transform
	var effect: GPUParticles2D = shoot_effect.instantiate()
	effect.transform = projectile_spawn_point.global_transform
	level.add_child(effect)
	set_energy(energy - 15)

func set_energy(value: int) -> void:
	if value > max_energy:
		energy = max_energy
	else:
		energy = value
		energy_changed.emit(value)

func handle_hit() -> void :
	player_death.emit()
	$DeathParticles.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	dead = true
	await get_tree().create_timer(3.0).timeout
	queue_free()
