extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play("start")

func _process(_delta) -> void:
	if animated_sprite_2d.is_playing() == false:
		queue_free()
