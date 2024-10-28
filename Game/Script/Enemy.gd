extends CharacterBody2D
class_name EnemyController

var speed : int = 50
var direction : int = -1
var current_health : int = 100
var is_dead : bool = false
var is_attacking : bool = false


@onready var ray_cast_2d_forward = $CollisionShape2D/RayCast2D_forward
@onready var ray_cast_2d_downward = $CollisionShape2D/RayCast2D_downward
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_2d_container = $Area2D_Container


func _process(_delta : float) -> void:
	updateAnimation()

func _physics_process(_delta : float) -> void:
	if is_on_floor() == false:
		velocity.y = 300
	if is_dead:
		return

	if is_attacking:
		if animated_sprite_2d.is_playing() == false:
			print("is attacking")
			is_attacking = false
		else:
			return
	
	if ray_cast_2d_forward.is_colliding() || ray_cast_2d_downward.is_colliding() == false:
		direction = -direction
		ray_cast_2d_forward.target_position.x = -ray_cast_2d_forward.target_position.x
		ray_cast_2d_downward.target_position.x = -ray_cast_2d_downward.target_position.x
		area_2d_container.scale.x = -direction
		
	velocity.x = direction * speed
	
	move_and_slide()
	
func updateAnimation() -> void:
	if is_dead:
		return
		
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
		
	if is_attacking == false:
		animated_sprite_2d.play("walk")
	elif animated_sprite_2d.animation != "attack":
		animated_sprite_2d.play("attack")

func applyDamage(damage : int) -> void:
	if is_dead:
		return
	current_health -= damage
	if current_health <= 0:
		is_dead = true
		animated_sprite_2d.play("die")
		set_collision_layer_value(3, false)
		await  get_tree().create_timer(2).timeout
		queue_free()


func _on_area_2d_player_detector_body_entered(body):
	print("body attacking signal")
	is_attacking = true
