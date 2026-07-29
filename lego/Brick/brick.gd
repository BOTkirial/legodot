@tool

extends LegoPiece

# The base class for assembling legos

class_name Brick

# config

static var pinSpace:float = 0.08
static var pinHeight:float = 0.015
static var pinDiameter:float = 0.045
static var brickHeightUnit:float = 0.095
static var flatBrickHeightUnit:float = 0.035
static var brickDepthUnit:float = 0.08

# parameters

@export var width: int = 2 :
	set(value):
		width = value
		update()

@export var depth: int = 2 :
	set(value):
		depth = value
		update()

@export var withStickyMale: bool = true :
	set(value):
		withStickyMale = value
		update()

@export var isFlat: bool = false :
	set(value):
		isFlat = value
		update()

@export var nbInsertableFemale: int = 0 :
	set(value):
		nbInsertableFemale = value
		update()

@export_enum("klip", "axle") var type: String = "klip" :
	set(value):
		type = value
		update()

@export_color_no_alpha var color: Color = Color.WHITE :
	set(value):
		color = value
		update()

# The components that make out the brick

@onready var brickBody:MeshInstance3D = $BrickBody as MeshInstance3D;
@onready var overlay:Overlay = $Overlay as Overlay;
@onready var stickyMaleSurface:StickyMaleSurface = $StickyMaleSurface as StickyMaleSurface;
@onready var stickyFemaleSurface:StickyFemaleSurface = $StickyFemaleSurface as StickyFemaleSurface;
@onready var draggable:Draggable = $Draggable as Draggable;
@onready var insertableFemaleSurface:InsertableFemaleSurface = $InsertableFemaleSurface as InsertableFemaleSurface;

@onready var material = preload("res://lego/Brick/BrickMaterial.tres")
@onready var brickClass = preload("res://lego/Brick/Brick.tscn")

func _ready() -> void:
	update()

func update():
	var brickHeight = flatBrickHeightUnit if isFlat else brickHeightUnit
	# Update the size of the brick's body
	if brickBody :
		brickBody.mesh.size = Vector3(brickDepthUnit * float(width), brickHeight, brickDepthUnit * float(depth))
		brickBody.material_override = material.duplicate() as StandardMaterial3D
		(brickBody.material_override as StandardMaterial3D).albedo_color = self.color
	# Update the size of the brick's overlay
	if overlay :
		overlay.hide()
		overlay.mesh.size = Vector3(brickDepthUnit * float(width) + 0.05, brickHeight + 0.05, brickDepthUnit * float(depth) + 0.05)
	# update the StickyMale surface
	if stickyMaleSurface :
		stickyMaleSurface.width = width
		stickyMaleSurface.depth = depth
		stickyMaleSurface.position = Vector3(-pinSpace * width / 2 + pinSpace / 2, (brickHeight + pinHeight) / 2, -pinSpace * depth / 2 + pinSpace / 2)
	# update the StickyFemale surface
	if stickyFemaleSurface :
		stickyFemaleSurface.width = width
		stickyFemaleSurface.depth = depth
		stickyFemaleSurface.position = Vector3(-pinSpace * width / 2 + pinSpace / 2, -(brickHeight) / 2 + pinHeight / 2 - 0.03, -pinSpace * depth / 2 + pinSpace / 2)
	# Update the size of the brick's draggable piece
	if draggable :
		var shape = draggable.get_child(0) as CollisionShape3D
		shape.shape.size = Vector3(brickDepthUnit * float(width), brickHeight, brickDepthUnit * float(depth))
	# Update the size of the brick's holes for insertables
	if insertableFemaleSurface :
		insertableFemaleSurface.width = nbInsertableFemale
		insertableFemaleSurface.depth = depth
		insertableFemaleSurface.position = Vector3(-pinSpace * nbInsertableFemale / 2 + pinSpace / 2, 0, -pinSpace * depth / 2 + pinSpace / 2)
		insertableFemaleSurface.type = type
	# update the visibility of stickymale surface
	if stickyMaleSurface :
		stickyMaleSurface.visible = withStickyMale

func instantiate_clone() -> Brick:
	var clone = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	clone.update()
	self.get_parent().add_child(clone)
	clone.overlay.show()
	clone.overlay.setColor(Overlay.COLOR_BLUE)
	clone.global_transform = self.global_transform
	return clone
