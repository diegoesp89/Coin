extends RigidBody3D

@export var Hud = load("res://Prefabs/Hud.tscn")


signal delete_coin()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(self.position.y < -2.0):
		print("killed")
		#$Hud.coin_deleted()
		queue_free()
	pass
