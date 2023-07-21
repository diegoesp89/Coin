extends Node

var coin = load("res://Prefabs/coin.tscn")
var level = load("res://Prefabs/scene1.tscn")

func spawn():
	print("Spawning")
	#add_child()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		spawn()
	pass
