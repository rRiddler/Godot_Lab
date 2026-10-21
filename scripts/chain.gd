extends Node2D
signal updateSlidersUI
@export var UI: Control
@export_category("Segment parameters")
@export_range(3,15) var segmentCount: int = 3:
	set(value):
		segmentCount = value
		#updateSlidersUI.emit()
@export_range(0.0,0.9) var radiusDegradation: float = 0.0:
	set(value):
		radiusDegradation = value
		#updateSlidersUI.emit()
@export_category("Drawing parameters")
@export_range(1.0,10.0) var width: float = 1.0:
	set(value):
		width = value
		#updateSlidersUI.emit()
@export_range(3.0,30.0) var radius: float = 3.0:
	set(value):
		radius = value
		#updateSlidersUI.emit()
@export_range(10.0,500.0) var pathRadius: float = 10.0:
	set(value):
		pathRadius = value
		#updateSlidersUI.emit()
@export_range(2.0,100.0) var distance: float = 2.0:
	set(value):
		distance = value
		#updateSlidersUI.emit()
# Importing external class
const Segment = preload("res://scripts/Segment.gd")
#
var segments: Array
var a: float = 0.0

func _update_values():
	# Resizing chain if segmentCount changed
	if segmentCount != segments.size():
		if segmentCount > segments.size():
			for i in range(segmentCount - segments.size()):
				var newSegment = Segment.new(radius*((1-radiusDegradation)**(i+segments.size())),global_position+Vector2(1,1)*i)
				segments.append(newSegment)
		elif segmentCount < segments.size():
			for i in range(segments.size()-segmentCount):
				segments[-1-i].queue_free()
			segments.resize(segmentCount)
	# Resizing individual chain link sizes if Radius changed
	if segments[0].radius-radius > 0.01 or segments[0].radius-radius < 0:
		segments[0].radius = radius
		for i in range(1,segments.size()):
			segments[i].radius = radius*((1-radiusDegradation)**i)
	# Resizing all segments if radiusDegradation changed
	if segments[1].radius-radius*(1-radiusDegradation) > 0.01 or segments[1].radius-radius*(1-radiusDegradation) < 0:
		for i in range(1,segments.size()):
			segments[i].radius = radius*((1-radiusDegradation)**i)
		
func _ready() -> void:
	updateSlidersUI.connect(_update_values) # GodotРедактор будет сразу обновлять отрисовку
	updateSlidersUI.connect(UI._update_values) # Пытаемся заставить наш интерфейс отображать корректно значения
	print("[INFO] {0}".format([segmentCount]))
	segments = Array()
	for i in range(segmentCount):
		var newSegment = Segment.new(radius*((1-radiusDegradation)**i),global_position+Vector2(1,1)*i)
		segments.append(newSegment)
func _process(delta: float) -> void:
	queue_redraw()
func _physics_process(delta: float) -> void:
	# Moving head in circles using Circle formula and 'a' as source for "changing" variable for trigonometry
	if a > 360.0:
		a -= 360.0
	a += 4.0 * delta	
	segments[0].global_position = Vector2(cos(a)*pathRadius,sin(a)*pathRadius)
	# Moving segments closer together
	for i in range(segments.size()-1):
		var s1: Segment = segments[i]
		var s2: Segment = segments[i+1]
		if (s2.global_position-s1.global_position).length() > distance+1.0:
			var vectorMove = (s2.global_position - s1.global_position) 
			var direction = vectorMove.normalized()
			var power = distance-vectorMove.length()
			s2.global_position += direction*power
	# Separating apart every segment from each other
	for s1: Segment in segments.slice(0,segments.size()):
		for s2: Segment in segments.slice(1,segments.size()):
			if (s2.global_position-s1.global_position).length() < distance:
				var vectorMove = (s2.global_position - s1.global_position) 
				var direction = vectorMove.normalized()
				var power = distance-vectorMove.length()
				s2.global_position += direction*power


func _draw() -> void:
	var prevSegment: Segment = segments[0]
	for segment: Segment in segments:
		draw_ellipse(segment.global_position,segment.radius,segment.radius,Color(255,255,255),false,width)
		if prevSegment:
			draw_line(prevSegment.global_position,segment.global_position,Color(200,200,200),width)
		prevSegment = segment
