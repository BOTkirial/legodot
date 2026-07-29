@tool

extends MeshInstance3D

class_name StickyFemalePin

var available:bool = true
@onready var overlay = $Overlay as Overlay

func _ready() -> void:
	setAvailable()

func setAvailable() :
	overlay.setColor(Overlay.COLOR_GREEN)
	available = true

func setUnAvailable():
	overlay.setColor(Overlay.COLOR_RED)
	available = false
