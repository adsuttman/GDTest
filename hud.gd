extends CanvasLayer

var energy_bar: ProgressBar
var score_counter: Label
var wave_notification: Label

func _ready():
	energy_bar = $EnergyBar
	score_counter = $Score
	wave_notification = $WaveNotification
	GameManager.score_updated.connect(update_score)
	GameManager.new_wave.connect(on_new_wave)

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

func on_new_wave(wave: int) -> void:
	wave_notification.text = "Wave " + str(wave)
	wave_notification.show()
	await get_tree().create_timer(1.0).timeout
	wave_notification.hide()
