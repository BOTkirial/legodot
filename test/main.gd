extends Node3D

var cubeClass = preload("res://test/physicsCube.tscn")
var sphereClass = preload("res://test/physicsSphere.tscn")

var count = 0
func _process(_delta: float) -> void:
	count += 1
	if count % 30 == 0:
		if RandomNumberGenerator.new().randf() > 0.5:
			var cube = cubeClass.instantiate()
			cube.position = $spawner.position
			add_child(cube)
		else :
			var sphere = sphereClass.instantiate()
			sphere.position = $spawner.position
			add_child(sphere)
			sphere.apply_impulse(Vector3(1.0, 0.0, 0.0))
