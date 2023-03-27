extends CanvasLayer

@export var player: PlayerCharacter
var energy_bar: ProgressBar

func _ready():
	energy_bar = $EnergyBar
	energy_bar.set_max(player.max_energy)
	energy_bar.set_value(player.energy)
	show()

func _process(delta):
	energy_bar.set_value(player.energy)
