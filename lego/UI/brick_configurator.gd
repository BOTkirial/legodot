extends Control

@onready var presetButton: CustomButton = $window/MarginContainer/VBoxContainer/HBoxContainerTabs/PresetButton
@onready var brickButton: CustomButton = $window/MarginContainer/VBoxContainer/HBoxContainerTabs/BrickButton
@onready var beamButton: CustomButton = $window/MarginContainer/VBoxContainer/HBoxContainerTabs/BeamButton
@onready var gearButton: CustomButton = $window/MarginContainer/VBoxContainer/HBoxContainerTabs/GearButton
@onready var axleButton: CustomButton = $window/MarginContainer/VBoxContainer/HBoxContainerTabs/AxleButton
@onready var engineButton: CustomButton = $window/MarginContainer/VBoxContainer/HBoxContainerTabs/EngineButton

enum MENUS { PRESET, BRICK, BEAM, GEAR, AXLE, ENGINE }
var currentMenu:MENUS = MENUS.PRESET

func _ready() -> void:
	presetButton.connect("on_click", func(): showMenu(MENUS.PRESET) )
	brickButton.connect("on_click", func(): showMenu(MENUS.BRICK) )
	beamButton.connect("on_click", func(): showMenu(MENUS.BEAM) )
	gearButton.connect("on_click", func(): showMenu(MENUS.GEAR) )
	axleButton.connect("on_click", func(): showMenu(MENUS.AXLE) )
	engineButton.connect("on_click", func(): showMenu(MENUS.ENGINE) )

func showMenu(menu: MENUS) -> void:
	print(menu)
