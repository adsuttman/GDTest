extends CharacterBody2D

class_name Enemy

@export var health: float = 100.0
@export var speed: float = 400
var target: PlayerCharacter = null
var victory_dance = false

func _ready():
	if target == null:
		target = get_tree().get_nodes_in_group("Player")[0]
		target.player_death.connect(on_player_death)

func _physics_process(delta) -> void:
	var collision = get_last_slide_collision()
	if collision != null:
		handle_collision(collision as KinematicCollision2D)
	if target != null:
		look_at(target.global_position)
		velocity = position.direction_to(target.position) * speed
		move_and_slide()
	if victory_dance:
		rotate(PI/24)

func apply_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		queue_free()

func handle_collision(collision: KinematicCollision2D) -> void:
	var object = collision.get_collider()
	if object is PlayerCharacter:
		object.handle_hit()


func on_player_death():
	victory_dance = true

