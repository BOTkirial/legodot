@tool

extends MeshInstance3D

class_name StickyMalePin

var available:bool = true
@onready var overlay = $Overlay as Overlay
@onready var material = preload("res://lego/Brick/BrickMaterial.tres")

func _ready() -> void:
	self.material_override = material.duplicate() as StandardMaterial3D
	(self.material_override as StandardMaterial3D).albedo_color = self.get_parent().get_parent().color

	var _mesh:CylinderMesh = self.mesh as CylinderMesh
	_mesh.bottom_radius = Brick.pinDiameter / 2
	_mesh.top_radius = Brick.pinDiameter / 2
	_mesh.height = Brick.pinHeight
	setAvailable()

func setAvailable() :
	overlay.setColor(Overlay.COLOR_GREEN)
	available = true

func setUnAvailable():
	overlay.setColor(Overlay.COLOR_RED)
	available = false
