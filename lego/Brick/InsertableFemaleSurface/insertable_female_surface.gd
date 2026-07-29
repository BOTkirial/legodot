@tool

extends Node3D

class_name InsertableFemaleSurface

var insertableFemaleSegmentClass = preload("res://lego/Brick/InsertableFemaleSurface/InsertableFemaleSegment/InsertableFemaleSegment.tscn")
var segments:Array[InsertableFemaleSegment] = []

@export_enum("klip", "axle") var type: String = "klip" :
	set(value):
		type = value
		update()

# exporte le nombre de receiver en largeur
@export var width: int = 1 :
	set(value):
		width = value
		update()

# la profondeur des segments
@export var depth: int = 1 :
	set(value):
		depth = value
		update()

# Est-ce qu'on autorise un placement de segments personnalisé ?
@export var allowCustomSegements: bool = false :
	set(value):
		allowCustomSegements = value
		update()

func _ready():
	update()

# méthode déclenchée lorsque le nombre de pins change
func update():
	for child in get_children():
		if child is InsertableFemaleSegment and !allowCustomSegements :
			segments.erase(child)
			child.queue_free()

	if !allowCustomSegements:
		for x in width:
			for z in depth:
				var insertableFemaleSegment = insertableFemaleSegmentClass.instantiate() as InsertableFemaleSegment
				insertableFemaleSegment.type = type
				insertableFemaleSegment.position = Vector3(float(x) * Brick.pinSpace, 0, float(z) * Brick.pinSpace)
				segments.push_back(insertableFemaleSegment)
				add_child(insertableFemaleSegment)

	if allowCustomSegements:
		for child in get_children():
			if child is InsertableFemaleSegment :
				segments.push_back(child)

func findSnappableSegments() -> Dictionary :
	var maleMatches:Array[InsertableMaleSegment] = []
	var femaleMatches:Array[InsertableFemaleSegment] = []
	var maleSegments = Utils.getAllMaleInsertableSegments()
	for femaleSegment:InsertableFemaleSegment in segments :
		for maleSegment:InsertableMaleSegment in maleSegments :
			if !(self.get_parent() in Utils.get_ancestors(maleSegment)) :
				var distance = femaleSegment.global_position.distance_to(maleSegment.global_position)
				if distance < 0.05 and maleSegment.type == femaleSegment.type :
					maleMatches.push_back(maleSegment)
					femaleMatches.push_back(femaleSegment)

	return {
		"males": maleMatches,
		"females": femaleMatches
	}

func findSnapTransform() -> Transform3D :
	var matches = self.findSnappableSegments()
	var maleSegments = matches.males as Array[InsertableMaleSegment]
	var femaleSegments =  matches.females as Array[InsertableFemaleSegment]

	for maleSegment in maleSegments:
		if !maleSegment.available :
			return Transform3D()
	for femaleSegment in femaleSegments:
		if !femaleSegment.available :
			return Transform3D()

	if(maleSegments.size() > 0 && femaleSegments.size() > 0):
		var maleSegment:InsertableMaleSegment = maleSegments[0]
		var femaleSegment:InsertableFemaleSegment = femaleSegments[0]
		var brick = self.get_parent()
		var insertable = maleSegment.get_parent()

		var transformSave = brick.global_transform

		var offset = femaleSegment.global_position - maleSegment.global_position
		brick.global_transform.basis = insertable.global_transform.basis
		brick.global_position -= offset
		var axis = insertable.global_transform.basis.y.normalized()
		var angle = Utils.closest_angle(
			Utils.getAngleBetweenNodes(brick, insertable),
			[PI / 2, 3 * PI / 2]
		)
		Utils.rotate_around_pivot(brick, maleSegment.global_position, axis, angle)
		var new_transform = brick.global_transform

		brick.global_transform = transformSave
		return new_transform

	return Transform3D()



	#if(maleSegments.size() > 0 && femaleSegments.size() > 0):
		#var maleSegment:InsertableMaleSegment = maleSegments[0]
		#var femaleSegment:InsertableFemaleSegment = femaleSegments[0]
		#var brick = self.get_parent()
		#var insertable = maleSegment.get_parent()
#
		#var transformSave = brick.global_transform
		#var saveAngle = Utils.getAngleBetweenNodes(brick, insertable)
#
		#brick.basis = insertable.global_transform.basis
		#var distance = maleSegment.global_position.distance_to(femaleSegment.global_position)
		#var offset = maleSegment.global_position.direction_to(femaleSegment.global_position) * distance
		#brick.position -= offset
		#Utils.rotate_around_pivot(brick, maleSegment.global_position, Vector3.UP, Utils.closest_angle(saveAngle, [PI / 2, 3 * PI / 2]))
		#var newTransform = brick.global_transform
#
		#brick.global_transform = transformSave
		#return newTransform
