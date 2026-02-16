extends RigidBody3D

@export var Hud = load("res://Prefabs/Hud.tscn")
@export var bounds_y = -2.0
@export var bounds_x = 10.0
@export var bounds_z = 10.0

signal delete_coin(coin_name: String)

func _physics_process(_delta):
	if position.y < bounds_y or position.y > bounds_x or \
	   abs(position.x) > bounds_x or abs(position.z) > bounds_z:
		var coin_name = name if name != "Coin" else "default"
		delete_coin.emit(coin_name)
		queue_free()
