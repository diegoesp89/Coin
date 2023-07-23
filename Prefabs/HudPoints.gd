extends RichTextLabel
var counter = 0

signal delete()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "Start"
	delete.emit()
	pass # Replace with function body.
	
func coin_deleted():
	counter += 1
	self.text = str(counter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("coin_deleted"):
		coin_deleted()
	pass


func _on_delete():
	coin_deleted()
	pass # Replace with function body.
