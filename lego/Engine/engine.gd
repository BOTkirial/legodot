@tool

extends LegoPiece

class_name LegoEngine

# les éléments 3D

@onready var overlay:Overlay = $Overlay as Overlay;
@onready var stickyFemaleSurface:StickyFemaleSurface = $StickyFemaleSurface as StickyFemaleSurface;
@onready var draggable:Draggable = $Draggable as Draggable;
@onready var engineFemaleSegment:InsertableFemaleSegment = $InsertableFemaleSurface/EngineAxle as InsertableFemaleSegment;
@onready var insertableFemaleSurface:InsertableFemaleSurface = $InsertableFemaleSurface as InsertableFemaleSurface;
@onready var engineButtonContainer = get_tree().get_current_scene().get_node("EngineButtons_MarginContainer/EngineButtons_HorizontalContainer")

# les classes pour l'instantiation

@onready var EngineClass = preload("res://lego/Engine/Engine.tscn")
@onready var ButtonClass = preload("res://lego/UI/Components/Button.tscn")

# les propriétés du moteur

@export var maxPower: float = 500.0 : # puissance maximale consommée en W
	set(value):
		maxPower = value

@export var inputCurrent: float = 1.0 : # courant fournit en Ampère (A)
	set(value):
		inputCurrent = value

@export var kt: float = 0.1 : # Coefficient de rendement pour le couple (en Nm/A)
	set(value):
		kt = value

@export var inputVoltage: float = 12.0 : # tension fournie en Volts (V)
	set(value):
		inputVoltage = value

@export var ks: float = 0.1 : # Coefficient de rendement pour la vitesse (en V/rad/s)
	set(value):
		ks = value

var running:bool = false
var speed_rads:float = 0.0
var torque_nm: float = 0.0

func _ready() -> void:
	var button: CustomButton = ButtonClass.instantiate() as CustomButton
	button.text = "Allumer le moteur"
	button.custom_minimum_size = Vector2(200, 70)
	button.FONT_SIZE = 18
	button.connect("on_click", toggleRunning)
	engineButtonContainer.add_child(button)

func toggleRunning() -> void:
	# met à jour l'état du moteur
	running = !running
	# met à jour la vitesse de rotation et le torque
	if running :
		self.speed_rads = MechanicUtils.get_current_speed_rads(self.inputVoltage, self.inputCurrent, self.ks)
		self.torque_nm = MechanicUtils.get_current_torque_nm(self.inputCurrent, self.kt)
	else :
		self.speed_rads = 0.0
		self.torque_nm = 0.0
	# transmet la vitesse de rotation et le torque à l'axe du moteur
	var engineMaleSegment = self.engineFemaleSegment.findInsertedMaleSegement() as InsertableMaleSegment
	if engineMaleSegment :
			var engineAxle = engineMaleSegment.get_parent() as Insertable
			engineAxle.input_speed_rads = self.speed_rads
			engineAxle.input_torque_nm = self.torque_nm


func instantiate_clone() -> LegoEngine:
	var clone = self.duplicate(DUPLICATE_USE_INSTANTIATION)
	self.get_parent().add_child(clone)
	clone.overlay.show()
	clone.overlay.setColor(Overlay.COLOR_BLUE)
	clone.global_transform = self.global_transform
	return clone
