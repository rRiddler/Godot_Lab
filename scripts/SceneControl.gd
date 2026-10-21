extends Node2D
var mainCamera: Camera2D

func _ready() -> void:
	mainCamera = get_tree().get_first_node_in_group('mainCamera')

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mainCamera.zoom.length() > 0.5:
				mainCamera.zoom *= 0.9
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and mainCamera.zoom.length() < 5.0:
				mainCamera.zoom *= 1.1
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				mainCamera.global_position = get_global_mouse_position()
