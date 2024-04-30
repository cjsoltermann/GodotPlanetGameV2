extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var acc = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation.x += delta
	rotation.y += delta / 5
	rotation.z += delta / 3
	position.y = 2 * cos(acc)
	acc += delta
	pass
