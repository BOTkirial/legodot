@tool

extends Control

class_name CustomButton

var mouseIn:bool = false

@onready var backgroundPolygon:Polygon2D = $backgroundPolygon as Polygon2D
@onready var backgroundPolygonLines:Line2D = $backgroundPolygon/backgroundPolygonLines as Line2D
@onready var frontPolygon:Polygon2D = $frontPolygon as Polygon2D
@onready var frontPolygonLines:Line2D = $frontPolygon/frontPolygonLines as Line2D
@onready var frontLine:Line2D = $frontPolygon/frontLine as Line2D
@onready var label:Label = $Label as Label

@onready var BUTTON_WIDTH = self.size.x
@onready var BUTTON_HEIGHT = self.size.y

const BUTTON_SPACE_MOVE = 2.0

@export var BUTTON_SPACE:float = 10.0 :
	set(value):
		BUTTON_SPACE = value
		setup()

@export var BORDER_WIDTH:float = 5.0 :
	set(value):
		BORDER_WIDTH = value
		setup()

@export var FONT_SIZE:int = 24 :
	set(value):
		FONT_SIZE = value
		setup()

@export var text:String = "button" :
	set(value):
		text = value
		setup()

@export_color_no_alpha var color: Color = Color.MEDIUM_VIOLET_RED :
	set(value):
		color = value
		setup()

signal on_click

@onready var backgroundPoints:PackedVector2Array
@onready var backgroundPoints_mouseIn:PackedVector2Array
@onready var backgroundPoints_click:PackedVector2Array
@onready var frontPoints:PackedVector2Array
@onready var frontPoints_mouseIn:PackedVector2Array
@onready var frontPoints_click:PackedVector2Array
@onready var frontLinePoints:PackedVector2Array
@onready var frontLinePoints_mouseIn:PackedVector2Array
@onready var frontLinePoints_click:PackedVector2Array

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		BUTTON_WIDTH = self.size.x
		BUTTON_HEIGHT = self.size.y
		setup()

var isReady:bool = false

func _ready() -> void:
	isReady = true
	setup()

func setup() -> void:
	if isReady:
		backgroundPoints = PackedVector2Array([
			Vector2(BUTTON_SPACE + BUTTON_SPACE_MOVE, 0.0),
			Vector2(0.0, BUTTON_SPACE + BUTTON_SPACE_MOVE),
			Vector2(0.0, BUTTON_HEIGHT),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE - BUTTON_SPACE_MOVE, BUTTON_HEIGHT),
			Vector2(BUTTON_WIDTH, BUTTON_HEIGHT - BUTTON_SPACE - BUTTON_SPACE_MOVE),
			Vector2(BUTTON_WIDTH, 0.0)
		])
		backgroundPoints_mouseIn = PackedVector2Array([
			Vector2(BUTTON_SPACE, BUTTON_SPACE_MOVE),
			Vector2(0.0, BUTTON_SPACE + BUTTON_SPACE_MOVE),
			Vector2(0.0, BUTTON_HEIGHT),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE - BUTTON_SPACE_MOVE, BUTTON_HEIGHT),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE_MOVE, BUTTON_HEIGHT - BUTTON_SPACE),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE_MOVE, BUTTON_SPACE_MOVE)
		])
		backgroundPoints_click = PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(0.0, 0.0),
			Vector2(0.0, 0.0),
			Vector2(0.0, 0.0),
			Vector2(0.0, 0.0),
			Vector2(0.0, 0.0)
		])
		frontPoints = PackedVector2Array([
			Vector2(BUTTON_SPACE + BUTTON_SPACE_MOVE, BUTTON_HEIGHT - BUTTON_SPACE - BUTTON_SPACE_MOVE),
			Vector2(BUTTON_SPACE + BUTTON_SPACE_MOVE, 0.0),
			Vector2(BUTTON_WIDTH, 0.0),
			Vector2(BUTTON_WIDTH, BUTTON_HEIGHT - BUTTON_SPACE - BUTTON_SPACE_MOVE)
		])
		frontPoints_mouseIn = PackedVector2Array([
			Vector2(BUTTON_SPACE, BUTTON_HEIGHT - BUTTON_SPACE),
			Vector2(BUTTON_SPACE, BUTTON_SPACE_MOVE),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE_MOVE, BUTTON_SPACE_MOVE),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE_MOVE, BUTTON_HEIGHT - BUTTON_SPACE)
		])
		frontPoints_click = PackedVector2Array([
			Vector2(0.0, BUTTON_HEIGHT),
			Vector2(0.0, BUTTON_SPACE),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE, BUTTON_SPACE),
			Vector2(BUTTON_WIDTH - BUTTON_SPACE, BUTTON_HEIGHT)
		])
		frontLinePoints = PackedVector2Array([
			Vector2(0.0, BUTTON_HEIGHT),
			Vector2(BUTTON_SPACE + BUTTON_SPACE_MOVE, BUTTON_HEIGHT - BUTTON_SPACE - BUTTON_SPACE_MOVE)
		])
		frontLinePoints_mouseIn = PackedVector2Array([
			Vector2(0.0, BUTTON_HEIGHT),
			Vector2(BUTTON_SPACE, BUTTON_HEIGHT - BUTTON_SPACE)
		])
		frontLinePoints_click = PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(0.0, 0.0)
		])
		# connects the signals
		if !self.is_connected("mouse_entered", _on_mouse_entered) :
			self.connect("mouse_entered", _on_mouse_entered)
			self.connect("mouse_exited", _on_mouse_exited)
		# set the points
		backgroundPolygon.polygon = backgroundPoints
		backgroundPolygonLines.points = backgroundPoints
		frontPolygon.polygon = frontPoints
		frontPolygonLines.points = frontPoints
		frontLine.points = frontLinePoints
		# set the width of the lines
		frontLine.width = BORDER_WIDTH
		backgroundPolygonLines.width = BORDER_WIDTH
		frontPolygonLines.width = BORDER_WIDTH
		# label
		label.add_theme_font_size_override("font_size", FONT_SIZE)
		label.position = Vector2(BUTTON_SPACE, 0.0)
		label.custom_minimum_size = Vector2.ZERO
		label.size = Vector2(BUTTON_WIDTH - BUTTON_SPACE, BUTTON_HEIGHT - BUTTON_SPACE)
		label.text = text
		# colors
		backgroundPolygon.color = self.color
		frontPolygon.color = self.color

func _on_mouse_entered():
	mouseIn = true
	backgroundPolygon.polygon = backgroundPoints_mouseIn
	backgroundPolygonLines.points = backgroundPoints_mouseIn
	frontLine.points = frontLinePoints_mouseIn
	frontPolygon.polygon = frontPoints_mouseIn
	frontPolygonLines.points = frontPoints_mouseIn
	label.position = Vector2(BUTTON_SPACE - BUTTON_SPACE_MOVE, BUTTON_SPACE_MOVE)

func _on_mouse_exited():
	mouseIn = false
	backgroundPolygon.polygon = backgroundPoints
	backgroundPolygonLines.points = backgroundPoints
	frontLine.points = frontLinePoints
	frontPolygon.polygon = frontPoints
	frontPolygonLines.points = frontPoints
	label.position = Vector2(BUTTON_SPACE, 0.0)

func _input(event: InputEvent) -> void:
	if mouseIn:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				backgroundPolygon.polygon = backgroundPoints_click
				backgroundPolygonLines.points = backgroundPoints_click
				frontPolygon.polygon = frontPoints_click
				frontPolygonLines.points = frontPoints_click
				frontLine.points = frontLinePoints_click
				label.position = Vector2(0.0, BUTTON_SPACE)
				emit_signal("on_click")
			if event.button_index == MOUSE_BUTTON_LEFT and !event.is_pressed():
				backgroundPolygon.polygon = backgroundPoints_mouseIn
				backgroundPolygonLines.points = backgroundPoints_mouseIn
				frontPolygon.polygon = frontPoints_mouseIn
				frontPolygonLines.points = frontPoints_mouseIn
				frontLine.points = frontLinePoints_mouseIn
				label.position = Vector2(BUTTON_SPACE - BUTTON_SPACE_MOVE, BUTTON_SPACE_MOVE)
