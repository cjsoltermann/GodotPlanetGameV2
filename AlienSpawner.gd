extends Node3D

var alien_scene := preload("res://alien.tscn")

var spawn_hook: Callable
var spawn_root: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn(n: int):
	for _i in range(n):
		var alien = alien_scene.instantiate()
		alien.position = position
		if spawn_hook:
			spawn_hook.call(alien)
		spawn_root.add_child(alien)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
