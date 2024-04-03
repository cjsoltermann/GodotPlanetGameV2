class_name Character
extends CharacterBody3D

@onready var head: Node3D = $Body/Neck/Head
@onready var camera: Camera3D = $Body/Neck/Head/Camera3D
@onready var body: Node3D = $Body
@onready var inside_stuff: Node3D = $Body/Neck/Head/Camera3D/InsideRightArm
@onready var shoot_raycast: RayCast3D = $Body/Neck/Head/Camera3D/ShootRayCast
@onready var pickup_raycast: RayCast3D = $Body/Neck/Head/Camera3D/PickUpRayCast

@onready var crosshair_1: ColorRect = $ColorRect
@onready var crosshair_2: ColorRect = $ColorRect2

@export var dir := Vector3.ZERO
@export var sprinting := false

@export var speed := 10
@export var sprint_speed := 20
@export var jump_power := 25

@export var mass := 100

var has_double: bool = true

var picking_up_parent: Node3D = null
var picking_up : Node3D = null

var get_gravity: Callable
var get_closest_body: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	
	var cur_speed: float
	if sprinting:
		cur_speed = sprint_speed
	else:
		cur_speed = speed
	
	var dir := basis * body.basis * dir
	
	dir *= cur_speed
	velocity += dir
	
	move_and_slide()
	
	if is_on_floor():
		has_double = true
	
func jump():
	if is_on_floor():
		velocity += jump_power * basis.y
	elif has_double:
		velocity += jump_power * basis.y
		has_double = false

func head_move(delta_x: float, delta_y: float):
	body.rotate(body.basis.y, -delta_x / 150.0)
	head.rotate_x(delta_y / 150.0)
	body.orthonormalize()
	
func shoot():
	if shoot_raycast.is_colliding():
		var obj = shoot_raycast.get_collider()
		if "on_hit" in obj:
			obj.on_hit()
			
func try_pickup():
	if not picking_up and pickup_raycast.is_colliding():
		var obj := pickup_raycast.get_collider()
		if not obj.is_in_group("PickUp"):
			return
		picking_up = obj
		picking_up_parent = obj.get_parent()
		obj.set_physics_process(false)
		obj.reparent(camera)
	elif picking_up:
		picking_up.set_physics_process(true)
		picking_up.reparent(picking_up_parent)
		picking_up = null


func _input(event):
	if event.is_action_pressed("Release Mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	elif event.is_action_pressed("Forward"):
		dir.z = 1.0
	elif event.is_action_pressed("Backward"):
		dir.z = -1.0
	elif event.is_action_released("Forward") and not Input.is_action_pressed("Backward"):
		dir.z = 0.0
	elif event.is_action_released("Backward") and not Input.is_action_pressed("Forward"):
		dir.z = 0.0
	
	elif event.is_action_pressed("Left"):
		dir.x = 1.0	
	elif event.is_action_pressed("Right"):
		dir.x = -1.0
	elif event.is_action_released("Right") and not Input.is_action_pressed("Left"):
		dir.x = 0.0
	elif event.is_action_released("Left") and not Input.is_action_pressed("Right"):
		dir.x = 0.0
		
	elif event.is_action_pressed("Jump"):
		jump()
		
	elif event.is_action_pressed("Sprint"):
		sprinting = true
	elif event.is_action_released("Sprint"):
		sprinting = false
		
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
		head_move(event.relative.x, event.relative.y)
		if shoot_raycast.is_colliding():
			var obj = shoot_raycast.get_collider()
			if ("crosshair_color" in obj):
				crosshair_1.color = obj.crosshair_color
				crosshair_2.color = obj.crosshair_color
			else:
				crosshair_1.color = Color.WHITE
				crosshair_2.color = Color.WHITE
		else:
			crosshair_1.color = Color.WHITE
			crosshair_2.color = Color.WHITE
		
	elif event.is_action_pressed("Shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()
		
	elif event.is_action_pressed("Pick Up") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		try_pickup()
