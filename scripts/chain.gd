extends Node2D

@export_range(1.0,10.0) var width: float
@export_range(3.0,10.0) var radius: float
@export_range(0.0,0.9) var radiusDegradation: float
@export_range(2.0,15.0) var distance: float
@export_range(3,15) var segmentCount: int
const Segment = preload("res://scripts/Segment.gd")
var segments: Array

		

func _ready() -> void:
	segments = Array()
	for i in range(segmentCount):
		var newSegment = Segment.new(radius*((1-radiusDegradation)**i),global_position+Vector2(1,1)*i)
		segments.append(newSegment)
func _process(delta: float) -> void:
	queue_redraw()
func _physics_process(delta: float) -> void:
	# Moving head in circles using Circle formula and time as source for "changing" variable for trigonometry
	var elapsedTime = Time.get_ticks_usec()/(144000.0 * 4)
	segments[0].global_position = Vector2(cos(elapsedTime)*50,sin(elapsedTime)*50)
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
