extends Area3D

class_name Draggable

# different states the Draggable can be in

var mouseIn:bool = false
var dragging:bool = false
var snapping: bool = false

# A shared state accross all Draggables

static var anyDragging:bool = false

@onready var brick = self.get_parent()
var clone
var stickyClone

var planeHeight:float = 0.0

func _mouse_enter():
	mouseIn = true;

func _mouse_exit():
	mouseIn = false;

func _input(event):
	if event is InputEventMouseButton :

		# Initie un drag
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouseIn and !Utils.is_mouse_over_ui() :
			dragging = true
			anyDragging = true
			pickup()

		# Permet de monter / descendre l'objet
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and dragging and Input.is_key_pressed(KEY_SHIFT) :
			clone.global_position.y += 0.025

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and dragging and Input.is_key_pressed(KEY_SHIFT) :
			clone.global_position.y -= 0.025

		# Permet de faire tourner l'objet
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and dragging and !Input.is_key_pressed(KEY_SHIFT) :
			clone.rotation.y += PI / 16

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and dragging and !Input.is_key_pressed(KEY_SHIFT) :
			clone.rotation.y -= PI / 16

		# termine un drag et déclenche le drop
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed :
			if dragging :
				drop()
			dragging = false
			anyDragging = false

func _process(_delta: float) -> void:
	if dragging :
		whileDragging()

func pickup():
	if "stickyFemaleSurface" in brick :
		var snappedFemalePins = brick.stickyFemaleSurface.findSnappablePins()
		for pin in snappedFemalePins.StickyMalePins :
			(pin as StickyMalePin).setAvailable()
		for pin in snappedFemalePins.StickyFemalePins :
			(pin as StickyFemalePin).setAvailable()

	if "stickyMaleSurface" in brick :
		var snappedMalePins = brick.stickyMaleSurface.findSnappablePins()
		for pin in snappedMalePins.StickyMalePins :
			(pin as StickyMalePin).setAvailable()
		for pin in snappedMalePins.StickyFemalePins :
			(pin as StickyFemalePin).setAvailable()

	# récupère les segments connectés après le snap
	if "insertableFemaleSurface" in brick :
		var matches = brick.insertableFemaleSurface.findSnappableSegments()
		for male in matches.males :
			(male as InsertableMaleSegment).setAvailable()
		for female in matches.females :
			(female as InsertableFemaleSegment).setAvailable()

	planeHeight = brick.global_position.y
	clone = brick.instantiate_clone()
	stickyClone = brick.instantiate_clone()
	stickyClone.hide()

func drop():
	if snapping :
		brick.snap(stickyClone.global_transform)
	clone.queue_free()
	stickyClone.queue_free()

func whileDragging() -> void:

	# positionne l'objet sur la souris
	var fallbackPosition = Utils.ray_intersect_plane_from_camera(planeHeight)
	clone.global_position = Vector3(fallbackPosition.x, clone.global_position.y, fallbackPosition.z)

	# regarde si un snap est possible
	var snapTransform:Transform3D = clone.findSnapTransform()
	if snapTransform.origin.length() > 0 :
		stickyClone.show()
		stickyClone.global_transform = snapTransform
		stickyClone.overlay.setColor(Overlay.COLOR_GREEN)
		snapping = true
	else :
		stickyClone.hide()
		stickyClone.overlay.setColor(Overlay.COLOR_BLUE)
		snapping = false
