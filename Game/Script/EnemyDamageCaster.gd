extends Area2D

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var collision_shape_2d = $CollisionShape2D

const START_FRAME: int = 10
const END_FRAME: int = 13
const DAMAGE: int = 30


func _process(delta):
	if animated_sprite_2d.animation == "attack":
		if animated_sprite_2d.frame >= START_FRAME && animated_sprite_2d.frame <= END_FRAME:
			monitoring = true
			collision_shape_2d.visible = true
			return
	
	monitoring = false
	collision_shape_2d.visible = false
	

func _on_body_entered(body):
	var player = body as PlayerController
	if player:
		player.applyDamage(DAMAGE)

