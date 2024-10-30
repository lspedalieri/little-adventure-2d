extends CanvasLayer

@onready var health_bar : ProgressBar = $GameScreen/HealthBar
@onready var coin_label : Label = $GameScreen/CoinLabel
@onready var game_over_screen: Panel = $GameOverScreen



func _ready():
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
	player.playerHealthUpdated.connect(updateHealthBar)
	player.playerCoinUpdated.connect(updatedCoinLabel)
	GameManager.gameOver.connect(showGameOverScreen)
	game_over_screen.visible = false

func updateHealthBar(new_value:int, max_value:int):
	var bar_value = float(new_value)/float(max_value) * 100
	health_bar.value = bar_value


func updatedCoinLabel(new_value:int):
	coin_label.text = str(new_value)

func showGameOverScreen() -> void:
	game_over_screen.visible = true


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
