@tool

extends Node3D

class_name InsertableFemaleSegment

@export_enum("klip", "axle") var type: String = "klip" :
	set(value):
		type = value
		update()

var available:bool = true

@onready var overlay = $Overlay as Overlay

func update() -> void :
	if type == "klip" :
		$InsertableFemaleSegmentAxle.visible = false
		$InsertableFemaleSegmentKlip.visible = true
	if type == "axle" :
		$InsertableFemaleSegmentAxle.visible = true
		$InsertableFemaleSegmentKlip.visible = false

func _ready() -> void:
	add_to_group(Utils.GROUP_FEMALE_INSERTABLES)
	setAvailable()
	update()

func setAvailable() :
	overlay.setColor(Overlay.COLOR_GREEN)
	available = true

func setUnAvailable():
	overlay.setColor(Overlay.COLOR_RED)
	available = false

func findInsertedMaleSegement():
	var insertedMaleSegment = null
	if !self.available :
		var maleSegments = Utils.getAllMaleInsertableSegments()
		var minDistance = 1.0
		for maleSegment in maleSegments :
			if !maleSegment.available :
				var distance = self.global_position.distance_to(maleSegment.global_position)
				if distance < minDistance :
					minDistance = distance
					insertedMaleSegment = maleSegment

	return insertedMaleSegment
