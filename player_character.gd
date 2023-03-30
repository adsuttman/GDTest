extends CharacterBody2D

class_name PlayerCharacter

@export var speed_multiplier: float = 1.0
@export var projectile: PackedScene
@export var projectile_spawn_point: Marker2D
@export var boost_multiplier: float = 1.5
@export var max_energy: int = 100
@export var shoot_effect: PackedScene
const MOVE_SPEED: float = 500
var energy: int

signal energy_changed(value: int)
signal player_death()

func _ready() -> void:
	set_energy(max_energy)
	projectile_spawn_point = $ProjectileSpawnPoint


func _physics_process(delta: float) -> void:
	move()
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot") and energy > 0: shoot()

func move() -> void:
	var movement: Vector2 = Vector2.ZERO
	var boost = 1
#	print(energy)
	if Input.is_action_pressed("move_left"): movement.x -= 1.0
	if Input.is_action_pressed("move_right"): movement.x += 1.0
	if Input.is_action_pressed("move_up"): movement.y -= 1.0
	if Input.is_action_pressed("move_down"): movement.y += 1.0
	if Input.is_action_pressed("boost"):
		if energy > 0:
#			print("boosting...")
			boost = boost_multiplier
			set_energy(energy - 1)
		else:
#			print("out of energy!")
			pass
	else:
#		print("Regenerating energy...")
		set_energy(energy + 1)
	velocity = movement.normalized() * (MOVE_SPEED * speed_multiplier * boost)
#	print(velocity)
	move_and_slide()

func shoot() -> void :
	var inst: Projectile = projectile.instantiate()
	inst.spawned_from = self
	owner.add_child(inst)
	inst.transform = projectile_spawn_point.global_transform
	var effect: GPUParticles2D = shoot_effect.instantiate()
	effect.transform = projectile_spawn_point.global_transform
	owner.add_child(effect)
	energy -= 15

func set_energy(value: int) -> void:
	if value > max_energy:
		pass
	else:
		energy = value
		energy_changed.emit(value)

func handle_hit() -> void :
	player_death.emit()
	$DeathParticles.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(3.0).timeout
	queue_free()
