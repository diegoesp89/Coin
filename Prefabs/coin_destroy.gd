extends RigidBody3D

@export var Hud = load("res://Prefabs/Hud.tscn")
@export var bounds_y = -2.0
@export var bounds_x = 15.0
@export var bounds_z = 15.0

var player_name: String = "default"

signal delete_coin(coin_name: String)

func _physics_process(_delta):
	if position.y < bounds_y or position.y > bounds_x or \
	   abs(position.x) > bounds_x or abs(position.z) > bounds_z:
		delete_coin.emit(player_name)
		queue_free()
