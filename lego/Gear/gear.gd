@tool

extends LegoPiece

class_name Gear

@export_range(0, 50) var teethCount:int = 0

@export var inertiaMoment:float = 0.00125 : # le moment d'inertie en kg.m2
	set(value):
		inertiaMoment = value

var GearClass

@onready var overlay:Overlay = $Overlay as Overlay;
@onready var draggable:Draggable = $Draggable as Draggable;
@onready var insertableFemaleSurface:InsertableFemaleSurface = $InsertableFemaleSurface as InsertableFemaleSurface;

func _ready() -> void:
	GearClass = load(str("res://lego/Gear/Scenes/Gear_", teethCount,  ".tscn"))

func instantiate_clone() -> Gear:
	var clone = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	self.get_parent().add_child(clone)
	clone.overlay.show()
	clone.overlay.setColor(Overlay.COLOR_BLUE)
	clone.global_transform = self.global_transform
	return clone
