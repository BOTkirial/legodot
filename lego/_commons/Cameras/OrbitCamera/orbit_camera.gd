extends Node3D


@export var rotation_speed := 0.01
@export var zoom_speed := 0.1
@export var min_distance := 2.0
@export var max_distance := 20.0

@onready var camera = $Camera3D

func _ready() -> void:
	camera.position = Vector3(0.0, 0.0, 5.0)


func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		rotation.y -= event.relative.x * rotation_speed
		rotation.x -= event.relative.y * 0.01
		$Camera3D.look_at(position)

	if event is InputEventMouseButton and !Draggable.anyDragging and !DraggableInsertable.anyDragging:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z += zoom_speed
