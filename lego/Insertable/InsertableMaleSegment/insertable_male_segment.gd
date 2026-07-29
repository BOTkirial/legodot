@tool

extends Node3D

class_name InsertableMaleSegment

@export_enum("klip", "axle") var type: String = "klip" :
	set(value):
		type = value
		update()

var available:bool = true

@onready var overlay = $Overlay as Overlay

func update() -> void :
	if type == "klip" :
		$InsertableMaleSegmentAxle.visible = false
		$InsertableMaleSegmentKlip.visible = true
	if type == "axle" :
		$InsertableMaleSegmentKlip.visible = false
		$InsertableMaleSegmentAxle.visible = true

func _ready() -> void:
	add_to_group(Utils.GROUP_MALE_INSERTABLES)
	setAvailable()
	update()

func setAvailable() :
	overlay.setColor(Overlay.COLOR_GREEN)
	available = true

func setUnAvailable():
	overlay.setColor(Overlay.COLOR_RED)
	available = false
