extends Area2D

class_name Projectile

@export var speed: float = 40.0

func _physics_process(delta: float) -> void:
	position += transform.x * speed


func _on_timer_timeout():
	queue_free()
