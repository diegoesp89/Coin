extends Node

@export var coin_prefab = load("res://Prefabs/coin.tscn")
@export var level: PackedScene = load("res://Prefabs/scene1.tscn")
@export var count = 0
@export var Shooter: Node

func spawn():
	var coin = coin_prefab.instantiate()
	add_child(coin)
	count+=1
	print(count)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_key_pressed(KEY_SPACE):
		spawn()
	pass
