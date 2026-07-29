@tool

extends Node3D

class_name Insertable

# config commune à tous les axes

static var diameter:float = 0.05
static var segmentLength:float = 0.08

# paramètre entrants de chaque pièces

@export_enum("klip", "axle") var type: String = "klip" : # klip rond ou axe en croix ?
	set(value):
		type = value
		update()

@export var length: int : # la longueur en unité de l'axe
	set(value):
		length = value
		update()

# classes pour l'instantiation

var insertableSegmentClass = preload("res://lego/Insertable/InsertableMaleSegment/InsertableMaleSegment.tscn")

# Références au nodes enfants

@onready var draggable:DraggableInsertable = $DraggableInsertable as DraggableInsertable
@onready var overlay: Overlay = $Overlay as Overlay
@onready var collisionShape: CollisionShape3D = $DraggableInsertable/CollisionShape3D as CollisionShape3D

# propriétés spécifiques

var segments:Array[InsertableMaleSegment] = []
var connected_gears:Array[Gear] = []
var input_speed_rads:float = 0.0
var input_torque_nm: float = 0.0

func _ready():
	update()

# méthode déclenchée lorsque le nombre de pins change
func update():
	# Update the segments of the insertable's body
	for child in get_children():
		if child is InsertableMaleSegment :
			segments.erase(child)
			child.queue_free()

	for x in length:
		var insertableSegment = insertableSegmentClass.instantiate() as InsertableMaleSegment
		insertableSegment.type = type
		insertableSegment.position = Vector3(float(x) * self.segmentLength, 0, 0)
		segments.push_back(insertableSegment)
		add_child(insertableSegment)

	# Update the size of the brick's overlay
	if overlay :
		overlay.hide()
		overlay.mesh.size = Vector3(self.segmentLength * self.length, self.diameter, self.diameter)
		overlay.position.x = - self.segmentLength / 2 + 0.5 * self.segmentLength * self.length
	# Update the collision shape 3D
	if collisionShape :
		(collisionShape.shape as CylinderShape3D).height = self.segmentLength * self.length
		collisionShape.position.x = - self.segmentLength / 2 + 0.5 * self.segmentLength * self.length

func findSnappableSegments() -> Dictionary :
	var maleMatches:Array[InsertableMaleSegment] = []
	var femaleMatches:Array[InsertableFemaleSegment] = []
	var femaleSegments = Utils.getAllFemaleInsertableReceivers()
	for femaleSegment:InsertableFemaleSegment in femaleSegments :
		if !(self in Utils.get_ancestors(femaleSegment)) :
			for maleSegment:InsertableMaleSegment in segments :
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
		var brick = femaleSegment.get_parent().get_parent()

		var transformSave = self.global_transform
		var saveAngle = Utils.getAngleBetweenNodes(self, brick)

		Utils.move_to_root(self)
		self.basis = brick.global_transform.basis
		var distance = femaleSegment.global_position.distance_to(maleSegment.global_position)
		var offset = femaleSegment.global_position.direction_to(maleSegment.global_position) * distance
		self.position -= offset
		Utils.rotate_around_pivot(self, femaleSegment.global_position, Vector3.UP, Utils.closest_angle(saveAngle, [PI / 2, 3 * PI / 2]))
		var newTransform = self.global_transform

		self.global_transform = transformSave
		return newTransform

	return Transform3D()

func snap(newTransform: Transform3D) -> void:
	self.global_transform = newTransform

	var targetPiece:LegoPiece = null

	# récupère les segments connectés après le snap
	var matches = self.findSnappableSegments()

	for segment in matches.males :
		(segment as InsertableMaleSegment).setUnAvailable()
	for segment in matches.females :
		(segment as InsertableFemaleSegment).setUnAvailable()

	if !targetPiece && matches.females.size() > 0:
		targetPiece = matches.females[0].get_parent().get_parent()
		self.reparent(targetPiece)

func instantiate_clone() -> Insertable:
	var clone = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	clone.update()
	self.get_parent().add_child(clone)
	clone.overlay.show()
	clone.overlay.setColor(Overlay.COLOR_BLUE)
	clone.global_transform = clone.global_transform
	return clone

func _process(_delta: float) -> void:
	self.rotate(self.basis.x, self.input_speed_rads)
