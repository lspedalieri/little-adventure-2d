extends Node

var player: CharacterBody2D
var player_original_pos: Vector2

func playerEnteredResetArea():
	player.position = player_original_pos


func spawnVFX(vfxToSpawn : Resource, position : Vector2):
	var vfxInstance = vfxToSpawn.instantiate()
	vfxInstance.global_position = position
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	return vfxInstance
