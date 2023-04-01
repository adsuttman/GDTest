extends CanvasLayer

var energy_bar: ProgressBar
var score_counter: Label
var wave_notification: Label
var player: PlayerCharacter
var wave: int = 1
var death_message: Label

func _ready():
	energy_bar = $EnergyBar
	score_counter = $Score
	wave_notification = $WaveNotification
	death_message = $DeathMessage
	setup(get_tree().get_first_node_in_group("Player"))
	GameManager.score_updated.connect(update_score)
	GameManager.new_wave.connect(on_new_wave)
	GameManager.restarted.connect(setup)

func setup(new_player):
	connect_to_player(new_player)
	energy_bar.show()
	score_counter.show()
	death_message.hide()
	on_new_wave(1)

func connect_to_player(new_player):
	player = new_player
	player.energy_changed.connect(_on_player_character_energy_changed)
	player.player_death.connect(_on_player_character_player_death)
	update_energy_bar(player.max_energy)
	update_score(0)

func update_energy_bar(value: int) -> void:
	energy_bar.set_value(value)


func _on_player_character_energy_changed(value):
	update_energy_bar(value)


func _on_player_character_player_death():
	energy_bar.hide()
	score_counter.hide()
	$DeathMessage/Report.text = "You survived until wave " + str(wave)\
		+ " with a final score of " + score_counter.text
	death_message.show()

func update_score(score: int) -> void:
	score_counter.text = str(score)

func on_new_wave(wave: int) -> void:
	self.wave = wave
	wave_notification.text = "Wave " + str(wave)
	wave_notification.show()
	await get_tree().create_timer(1.0).timeout
	wave_notification.hide()
