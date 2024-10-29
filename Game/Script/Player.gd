extends CharacterBody2D
class_name PlayerController

const SPEED:int = 180
const JUMP_VELOCITY:int = -450
const GRAVITY:int = 1800
const SHOOT_DURATION : float = 0.249
const SHOOTING_POSITION : int = 26
const MAX_HEALTH : int = 100

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shooting_point = $Shooting_Point

var airborne_last_frame = false
var is_shooting : bool = false
var current_health : int :
	set(new_value):
		current_health = new_value
		emit_signal("playerHealthUpdated", current_health, MAX_HEALTH)

enum PlayerStates {Normal, Hurt, Dead}

signal playerHealthUpdated(new_value, max_value)

var current_state : PlayerStates = PlayerStates.Normal:
	set(new_value):
		current_state = new_value
		match current_state:
			PlayerStates.Hurt:
				if is_on_floor():
					animated_sprite_2d.play("hit_stand")
				else:
					animated_sprite_2d.play("hit_jump")
			PlayerStates.Dead:
				animated_sprite_2d.play("die")
				set_collision_layer_value(2, false)


func _ready() -> void:
	current_health = MAX_HEALTH
	GameManager.player = self
	GameManager.player_original_pos = position
	

func _process(_delta) -> void:
	updateAnimation()

func _physics_process(delta) -> void:
	if is_on_floor() == false:
		velocity.y += GRAVITY * delta
		airborne_last_frame = true
	elif airborne_last_frame:
		playLandVFX()
		airborne_last_frame = false
		
	if current_state == PlayerStates.Hurt || current_state == PlayerStates.Dead:
		velocity.x = 0
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		playJumpUpVFX()
	
	var direction = Input.get_axis("left","right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("shoot"):
		tryToShoot()

	#per scendere dalle piattaforme one way
	if Input.is_action_pressed("down") && is_on_floor():
		position.y += 3
	
	move_and_slide()


func updateAnimation() -> void:
	if current_state == PlayerStates.Dead:
		return
	elif current_state == PlayerStates.Hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			current_state = PlayerStates.Normal
		
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		if velocity.x < 0:
			shooting_point.position.x = -SHOOTING_POSITION
		else:
			shooting_point.position.x = SHOOTING_POSITION
	if is_on_floor():
		if abs(velocity.x) >= 0.1:
			var playing_animation_frame = animated_sprite_2d.frame
			var playing_animation_name = animated_sprite_2d.animation
			if is_shooting:
				animated_sprite_2d.play("shoot_run")
				if playing_animation_name == "run":
					animated_sprite_2d.frame = playing_animation_frame
			else:
				if playing_animation_name == "shoot_run" && animated_sprite_2d.is_playing():
					pass
				else:
					animated_sprite_2d.play("run")
					
		else:
			if is_shooting:
				animated_sprite_2d.play("shoot")
			else:
				animated_sprite_2d.play("idle")
	else:
		if is_shooting:
			animated_sprite_2d.play("shoot_jump")
		else:		
			animated_sprite_2d.play("jump")

func playJumpUpVFX() -> void:
	var vfxToSpawn = preload("res://Game/Scene/vfx_jump_up.tscn")
	GameManager.spawnVFX(vfxToSpawn, global_position)

func playLandVFX() -> void:
	var vfxToSpawn = preload("res://Game/Scene/vfx_land.tscn")
	GameManager.spawnVFX(vfxToSpawn, global_position)
	

func shoot() -> void:
	var bullet_to_spawn = preload("res://Game/Scene/bullet.tscn")
	var bullet_instance = GameManager.spawnVFX(bullet_to_spawn, shooting_point.global_position)
	if animated_sprite_2d.flip_h:
		bullet_instance.direction = -1
	else:
		bullet_instance.direction = 1


func tryToShoot() -> void:
	if is_shooting:
		return
	
	is_shooting = true
	shoot()
	playFireVFX()
	await get_tree().create_timer(SHOOT_DURATION).timeout
	is_shooting = false
	
func playFireVFX():
	var vfxToSpawn = preload("res://Game/Scene/vfx_player_fire.tscn")
	var vfxInstance = GameManager.spawnVFX(vfxToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		vfxInstance.scale.x = -1


func applyDamage(damage : int) -> void:
	print("trying to apply damage ", current_state)
	if current_state == PlayerStates.Hurt || current_state == PlayerStates.Dead:
		return
		
	print("player damaged")
	current_health -= damage
	current_state = PlayerStates.Hurt
	if current_health <= 0:
		current_health = 0
		current_state = PlayerStates.Dead
