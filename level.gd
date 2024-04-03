extends Node3D

var character_scene := preload("res://character.tscn")
@onready var player_root := $Players
@onready var body_root := $Bodies
@onready var cows := $Bodies/Cows
@onready var aliens := $Bodies/Aliens

@onready var planets: Node3D = $Planets

func get_gravity(pos: Vector3) -> Vector3:
	#var planet := get_closest_body(pos)
	#var dir := planet.position - pos
	#return dir.normalized() * (10 * planet.mass / dir.length_squared())
	var ret := Vector3.ZERO
	for planet: Planet in planets.get_children():
		var dir := planet.position - pos
		ret += dir.normalized() * (10 * planet.mass / (dir.length_squared()))
	return ret
		
func get_closest_body(pos: Vector3) -> Node3D:
	var dist := INF
	if planets.get_child_count() > 0:
		var ret := planets.get_child(0)
		for planet: Planet in planets.get_children():
			var d := (planet.position - pos).length_squared()
			if (d < dist):
				dist = d
				ret = planet
		return ret
	else:
		return null

func get_closest_target(pos: Vector3) -> Node3D:
	var dist := INF
	if cows.get_child_count() > 0:
		var ret := cows.get_child(0)
		for cow: Node3D in cows.get_children():
			var d := (cow.position - pos).length_squared()
			if (d < dist):
				dist = d
				ret = cow
		return ret
	else:
		return null

func _ready():
	var character = character_scene.instantiate()
	character.get_gravity = get_gravity
	character.get_closest_body = get_closest_body
	player_root.add_child(character, true)

	for body_group in body_root.get_children():
		for body in body_group.get_children():
			if ("get_gravity" in body && "get_closest_body" in body):
				body.get_gravity = get_gravity
				body.get_closest_body = get_closest_body
				
	for alien in aliens.get_children():
		alien.get_closest_target = get_closest_target
