@tool

class_name StickyMaleSurface

extends Node3D

# exporte le nombre de pin en largeur
@export var width: int :
	set(value):
		width = value
		update()

# exporte le nombre de pin en profondeur
@export var depth: int :
	set(value):
		depth = value
		update()

var stickyMalePinClass = preload("res://lego/Brick/StickyMaleSurface/StickyMalePin/StickyMalePin.tscn")

func _ready():
	add_to_group(Utils.GROUP_STICKY_MALE_SURFACE)
	update()

# méthode déclenchée lorsque le nombre de pins change
func update():
	for child in get_children():
		child.queue_free()

	for x in width:
		for z in depth:
			var stickyPin = stickyMalePinClass.instantiate() as StickyMalePin
			stickyPin.position = Vector3(float(x) * Brick.pinSpace, 0, float(z) * Brick.pinSpace)
			add_child(stickyPin)

func findSnappablePins() -> Dictionary :
	var stickyFemaleSurfaces = Utils.getAllStickyFemaleSurfaces()
	var stickyMalePins:Array[StickyMalePin] = []
	var stickyFemalePins:Array[StickyFemalePin] = []
	for stickyFemaleSurface:StickyFemaleSurface in stickyFemaleSurfaces:
		if !(self.get_parent() in Utils.get_ancestors(stickyFemaleSurface)) :
			for stickyMalePin:StickyMalePin in self.get_children() :
				for stickyFemalePin:StickyFemalePin in stickyFemaleSurface.get_children() :
					var distance = stickyFemalePin.global_position.distance_to(stickyMalePin.global_position)
					if distance < 0.05 :
						stickyMalePins.push_back(stickyMalePin)
						stickyFemalePins.push_back(stickyFemalePin)

	return {
		"StickyMalePins": stickyMalePins,
		"StickyFemalePins": stickyFemalePins
	}

func findSnapTransform() -> Transform3D :
	var matches = findSnappablePins()
	var stickyMalePins = matches.StickyMalePins as Array[StickyMalePin]
	var stickyFemalePins =  matches.StickyFemalePins as Array[StickyFemalePin]

	for stickyMalePin in stickyMalePins:
		if !stickyMalePin.available :
			return Transform3D()
	for stickyFemalePin in stickyFemalePins:
		if !stickyFemalePin.available :
			return Transform3D()

	if(stickyMalePins.size() > 0 && stickyFemalePins.size() > 0):
		var stickyFemalePin:StickyFemalePin = stickyFemalePins[0]
		var stickyMalePin:StickyMalePin = stickyMalePins[0]
		var transformSave = self.get_parent().global_transform
		Utils.move_to_root(self.get_parent())
		var saveAngle = Utils.getAngleBetweenNodes(self.get_parent(), stickyFemalePin.get_parent())
		get_parent().basis = stickyFemalePin.get_parent().global_transform.basis
		var distance = stickyFemalePin.global_position.distance_to(stickyMalePin.global_position)
		var offset = stickyFemalePin.global_position.direction_to(stickyMalePin.global_position) * distance
		self.get_parent().position -= offset
		Utils.rotate_around_pivot(get_parent(), stickyFemalePin.global_position, Vector3.UP, Utils.closest_angle(saveAngle, [0.0, PI / 2, PI, 3 * PI / 2, 2 * PI]))
		var newTransform = get_parent().global_transform
		get_parent().global_transform = transformSave
		return newTransform

	return Transform3D()
