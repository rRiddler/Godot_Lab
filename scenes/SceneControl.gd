extends Node2D
@export var mainCamera: Camera2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mainCamera.zoom.length() > 0.5:
				mainCamera.zoom *= 0.9
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and mainCamera.zoom.length() < 5.0:
				mainCamera.zoom *= 1.1
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT:
				mainCamera.global_position = get_global_mouse_position()
