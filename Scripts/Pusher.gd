extends AnimatableBody3D

@export var mov = 0.0
@export var rate = 0.025
@export var top_range = 6.0
@export var bot_range = 0.0
@export var ani_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	ani_player.play("obs_move")
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	if(mov > top_range or mov < bot_range):
#		rate *= -1.0
#	#self.position.z += rate
#	#print(mov)
#	mov += rate
#	pass
