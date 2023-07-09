extends CSGBox3D

var mov = 0
export var rate = 0.01
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(mov > 1.7 or mov < 0):
		rate *= -1
	self.position.z += rate
	mov += rate
	print(mov)
	pass
