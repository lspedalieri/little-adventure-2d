extends CanvasLayer

@onready var health_bar : ProgressBar = $GameScreen/HealthBar


func _ready():
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
	player.playerHealthUpdated.connect(updateHealthBar)


func updateHealthBar(new_value:int, max_value:int):
	var bar_value = float(new_value)/float(max_value) * 100
	health_bar.value = bar_value
