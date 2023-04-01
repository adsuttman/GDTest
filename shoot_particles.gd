extends GPUParticles2D

@onready var timer: Timer = $Timer

func _ready():
	timer.timeout.connect(queue_free)
