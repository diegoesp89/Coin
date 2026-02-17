extends Node

@export var coin_prefab = load("res://Prefabs/coin.tscn")
@export var count = 0
@export var spawner: Node
@export var max_coins = 200
@export var spawn_force = 5.0
@export var cooldown = 0.5

var spawn_queue: int = 0
var cooldown_timer: float = 0.0
var is_cooldown: bool = false

func spawn():
	spawn_queue += 1

func _process(_delta):
	if Input.is_action_just_released("spawn_button"):
		spawn()
	
	if is_cooldown:
		cooldown_timer -= _delta
		if cooldown_timer <= 0:
			is_cooldown = false
			if spawn_queue > 0:
				_do_spawn()
	else:
		if spawn_queue > 0:
			_do_spawn()

func _do_spawn():
	if count >= max_coins:
		print("Max coins reached!")
		spawn_queue = 0
		return
	
	spawn_queue -= 1
	
	var pos_x_spawner = spawner.position.x
	var pos_y_spawner = spawner.position.y
	var pos_z_spawner = spawner.position.z
	var coin = coin_prefab.instantiate()
	coin.position.x = pos_x_spawner
	coin.position.y = pos_y_spawner
	coin.position.z = pos_z_spawner
	coin.rotation = Vector3(PI / 2, 0, 0)
	add_child(coin)
	coin.apply_central_impulse(Vector3(0, -spawn_force, 0))
	count += 1
	
	is_cooldown = true
	cooldown_timer = cooldown
	
	print("Coins: ", count, " | Queue: ", spawn_queue, " | Cooldown: ", "%.2f" % cooldown_timer)
