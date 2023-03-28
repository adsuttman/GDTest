extends Area2D

class_name Projectile

@export var speed: float = 40.0
@export var damage: float = 30.0
var spawned_from: Node

func _physics_process(delta: float) -> void:
	position += transform.x * speed


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body: Node2D):
	if body == spawned_from: return
	if body is Enemy:
		var enemy = body as Enemy
		enemy.apply_damage(damage)
	queue_free()
