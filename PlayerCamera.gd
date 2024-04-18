extends Camera3D

var trauma := 0.0
var decay := 2.0  # How quickly the shaking stops [0, 1]
var trauma_power := 2  # Trauma exponent. Use [2, 3]..
var max_roll = 0.05  # Maximum rotation in radians (use sparingly).
var max_offset = Vector2(.1, .075)  # Maximum hor/ver shake in pixels.

@onready var noise = FastNoiseLite.new()
var noise_y = 0


func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	


func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	noise_y += 25
	var amount = pow(trauma, trauma_power)
	rotation.y = (max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)) + PI
	rotation.x = (max_roll * amount * noise.get_noise_2d(noise.seed*2, noise_y)) 
	rotation.z = (max_roll * amount * noise.get_noise_2d(noise.seed*3, noise_y)) 
	h_offset = max_offset.x * amount * noise.get_noise_2d(noise.seed*4, noise_y)
	v_offset = max_offset.y * amount * noise.get_noise_2d(noise.seed*5, noise_y)
