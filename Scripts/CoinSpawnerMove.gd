extends Node

@export var mov = 0
@export var min_dist = -3
@export var max_dist = 3
@export var speed = 0.01
@export var x_pos = 0


signal set_pos_x()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_ṕos_x.emit()
	x_pos = self.position.x
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(mov > max_dist or mov < min_dist):
		speed *= -1.0
	self.position.x += speed
	set_pos_x()
	mov += speed
	pass
