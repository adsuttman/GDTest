extends CanvasLayer

var energy_bar: ProgressBar
var score_counter: Label

func _ready():
	energy_bar = $EnergyBar
	score_counter = $Score
	GameManager.score_updated.connect(update_score)

func _process(delta):
	pass

func update_energy_bar(value: int) -> void:
	energy_bar.set_value(value)


func _on_player_character_energy_changed(value):
	update_energy_bar(value)


func _on_player_character_player_death():
	energy_bar.hide()
	$DeathMessage.show()

func update_score(score: int) -> void:
	score_counter.text = str(score)
