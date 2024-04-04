extends CharacterBody3D

var crosshair_color: Color = Color.RED
var get_gravity: Callable
var get_closest_body: Callable

var get_closest_target: Callable
var get_swarm_velocity: Callable

var dead := false

var target: Node3D
var anchor_planet: Planet

@onready var explosion = $Explosion
@onready var ship = $Ship
@onready var collider = $CollisionShape3D

func _process(delta):
	if not target:
		target = get_closest_target.call(position)
		
	if not anchor_planet:
		anchor_planet = get_closest_body.call(position)

func _physics_process(delta):
	if anchor_planet:
		if (anchor_planet.global_position - global_position).length_squared() < 1000:
			var down := (anchor_planet.global_position - global_position).normalized()
			up_direction = -down
			var new_x := up_direction.cross(basis.z)
			var new_z := new_x.cross(up_direction)
			var new_quat := Basis(new_x, up_direction, new_z).get_rotation_quaternion()
			quaternion = quaternion.slerp(new_quat, 0.05)
		
	if get_swarm_velocity:
		velocity = get_swarm_velocity.call(position, velocity)
	move_and_slide()
	
	#position += basis.y / 10000000 * sin(Time.get_ticks_usec() / 1000000000000)

func on_hit():
	if not dead:
		ship.hide()
		explosion.show()
		explosion.play("explosion" + str(randi_range(1,3)))
		collider.queue_free()
		dead = true

func _on_explosion_done():
	queue_free()
