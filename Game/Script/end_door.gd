extends Area2D



func _on_body_entered(body):
	GameManager.playerEnteredTheEndDoor()
	#get_tree().reload_current_scene()
