extends Camera3D


# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _unhandled_input(event):
	if event.is_action_pressed("Debug Camera"):
		if not current:
			make_current()
		else:
			clear_current()
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
		camera_move(event.relative.x, event.relative.y)

func camera_move(delta_x: float, delta_y: float):
	rotate(basis.y, -delta_x / 150.0)
	rotate_x(delta_y / 150.0)
	orthonormalize()
