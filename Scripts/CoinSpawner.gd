extends Node

@export var coin_prefab = load("res://Prefabs/coin.tscn")
@export var count = 0
@export var spawner: Node

func spawn():
	var pos_x_spawner = spawner.position.x
	var pos_y_spawner = spawner.position.y
	var pos_z_spawner = spawner.position.z
	var coin = coin_prefab.instantiate()
	coin.position.x = pos_x_spawner
	coin.position.y = pos_y_spawner
	coin.position.z = pos_z_spawner
	add_child(coin)
	count+=1
	print(count)

	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("spawn_button"):
		spawn()
	pass
