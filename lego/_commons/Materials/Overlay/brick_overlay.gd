@tool

extends MeshInstance3D

class_name Overlay

@onready var material = preload("res://lego/_commons/Materials/Overlay/overlay_material.tres")

const alpha = 50.0 / 255.0
static var COLOR_BLUE = Color(100.0 / 255.0, 100.0 / 255.0, 255.0 / 255.0, alpha)
static var COLOR_RED = Color(255.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0, alpha)
static var COLOR_GREEN = Color(100.0 / 255.0, 255.0 / 255.0, 100.0 / 255.0, alpha)

func setColor(color: Color) -> void :
	self.material_override = material.duplicate() as StandardMaterial3D
	(self.material_override as StandardMaterial3D).albedo_color = color
