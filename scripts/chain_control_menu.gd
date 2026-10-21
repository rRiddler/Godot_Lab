extends Control
signal updateSlidersUI
var panelContainerPositionToggled 
var panelContainerPositionUnToggled 
var panel

@export var chainGD: Node2D
@onready var segmentCountSlider = $"CanvasLayer/Panel/HBoxContainer/VBoxContainer/VBoxContainer/segmentCountSlider"
@onready var radiusDegradationSlider = $"CanvasLayer/Panel/HBoxContainer/VBoxContainer/VBoxContainer/radiusDegradationSlider"
@onready var widthSlider = $"CanvasLayer/Panel/HBoxContainer/VBoxContainer/VBoxContainer2/widthSlider"
@onready var radiusSlider = $"CanvasLayer/Panel/HBoxContainer/VBoxContainer/VBoxContainer2/radiusSlider"
@onready var pathRadiusSlider = $"CanvasLayer/Panel/HBoxContainer/VBoxContainer/VBoxContainer2/pathRadiusSlider"
@onready var distanceSlider = $"CanvasLayer/Panel/HBoxContainer/VBoxContainer/VBoxContainer2/distanceSlider"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateSlidersUI.connect(chainGD._update_values)
	updateSlidersUI.connect(_load_new_values_to_chainNode2D)
	panel = $"CanvasLayer/Panel"
	var width = panel.size.x
	panelContainerPositionToggled = $"CanvasLayer/Panel".position
	panelContainerPositionUnToggled = Vector2(panelContainerPositionToggled.x+width-30,
												panelContainerPositionToggled.y)
	panel.position = panelContainerPositionUnToggled
	_update_values()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		panel.position = panelContainerPositionToggled
	else:
		panel.position = panelContainerPositionUnToggled
		
func _update_values():
	segmentCountSlider.value = chainGD.segmentCount
	radiusDegradationSlider.value = chainGD.radiusDegradation
	widthSlider.value = chainGD.width
	radiusSlider.value = chainGD.radius
	pathRadiusSlider.value = chainGD.pathRadius
	distanceSlider.value = chainGD.distance

func _load_new_values_to_chainNode2D():
	chainGD.segmentCount = segmentCountSlider.value
	chainGD.radiusDegradation = radiusDegradationSlider.value
	chainGD.width = widthSlider.value 
	chainGD.radius = radiusSlider.value 
	chainGD.pathRadius = pathRadiusSlider.value 
	chainGD.distance = distanceSlider.value

func on_any_slider_value_changed(value: float) -> void:
	updateSlidersUI.emit()
