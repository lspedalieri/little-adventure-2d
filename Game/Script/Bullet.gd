extends Area2D


@onready var bullet_sprite_2d = $Bullet_Sprite2D

const SPEED : int = 500
const DAMAGE : int = 35
var direction : int = 1

func _physics_process(delta):
	if direction == -1:
		bullet_sprite_2d.flip_h = true
	
	position.x += direction * SPEED * delta
	


func _on_body_entered(body):
	var vfxToSpawn = preload("res://Game/Scene/vfx_bullet_hit.tscn")
	var vfxInstance = GameManager.spawnVFX(vfxToSpawn, global_position)
	
	if direction == -1:
		vfxInstance.scale.x = -1
	var enemy = body as EnemyController
	if enemy:
		enemy.applyDamage(DAMAGE)
	queue_free()
