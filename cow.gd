extends CharacterBody3D

@export var mass := 100
@export var jump_power := 10

var get_gravity: Callable
var get_closest_body: Callable

var dir: Vector2

enum STATE {STILL, WALKING, JUMP, FLYING}
var state: STATE

func _process(delta):
	if state == STATE.STILL && randf() < 0.007:
		dir = 2 * Vector2(2 * (randf() - 0.5), 2 * (randf() - 0.5))
		state = STATE.WALKING
	
	elif state == STATE.WALKING && randf() < 0.007:
		dir = Vector2.ZERO
		state = STATE.STILL

func _physics_process(_delta):
	apply_floor_snap()
	
	var gravity: Vector3 = get_gravity.call(position)
	var closest_body : Node3D = get_closest_body.call(position)
	if closest_body:
		var down = (closest_body.position - position).normalized()
		velocity += gravity * _delta
		up_direction = -down
		
		var new_x := up_direction.cross(basis.z)
		var new_z := new_x.cross(up_direction)
		var new_quat := Basis(new_x, up_direction, new_z).get_rotation_quaternion()
		quaternion = quaternion.slerp(new_quat, 0.05)

	velocity -= basis.x * velocity.dot(basis.x)
	velocity -= basis.z * velocity.dot(basis.z)
	
	if state == STATE.WALKING:
		var new_x = basis.x * dir.x + basis.z * dir.y
		var new_z = new_x.cross(up_direction)
		var new_quat := Basis(new_x, up_direction, new_z).get_rotation_quaternion()
		quaternion = quaternion.slerp(new_quat, 0.01)
		
		velocity += basis.x * dir.x
		velocity += basis.z * dir.y
	
	move_and_slide()
	
func hop():
	velocity += jump_power * basis.y
	
func on_hit():
	hop()

func _unhandled_input(event):
	if event.is_action_pressed("TestButton"):
		hop()
