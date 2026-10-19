extends CharacterBody2D
@onready var head = $"head"
@onready var bodySegments = find_children("*","CollisionShape2D")
var importedBodySegments = []
@export var bodySegmentCount: int
@export var headRadius: int
@export_range(0.0,1.0) var segmentSizeDegradationPercent: float 

signal changedPosition
var holding_obj = false


func _ready() -> void:
	bodySegments.erase($"head/Area2D/CollisionShape2D")
	var prevSegment = head
	for i in range(bodySegmentCount):
		var newSegment = CollisionShape2D.new()
		newSegment.name = "segment"+str(i)
		add_child(newSegment)
		newSegment.shape = CircleShape2D.new()
		newSegment.shape.radius = prevSegment.shape.radius * (1.0-segmentSizeDegradationPercent)
		importedBodySegments.append(newSegment)
		prevSegment = newSegment
	bodySegments.append_array(importedBodySegments)
	changedPosition.connect(move_segments)

func _process(delta: float) -> void:
	queue_redraw()

func move_segments():
	var prevSegment:CollisionShape2D = null
	for segment: CollisionShape2D in bodySegments:
		if segment.name.contains("segment") or segment.name == "head":
			if segment.name.contains("segment"):
				if prevSegment == null:
					pass
				else:
					var mD = prevSegment.position - segment.position 
					var rOffset = segment.shape.radius + prevSegment.shape.radius
					var mPower = mD.length() - rOffset
					segment.position += mD.normalized() * mPower
			prevSegment = segment
	# в данный момент prevSegment - хвост
	
	for i in range(0,bodySegments.size()):
		for j in range(1,bodySegments.size()):
			if (i != bodySegments.size()-1 and do_collide(bodySegments[i],bodySegments[j])):
				fix_segments(bodySegments[i],bodySegments[j])
			# если текущая точка - хвост, то проверяем ее с головой, как "следующим" элементом
		if (i == bodySegments.size()-1 and do_collide(bodySegments[0],bodySegments[i]) ):
			fix_segments(bodySegments[0],bodySegments[i])

func do_collide(seg1: CollisionShape2D,seg2: CollisionShape2D):
	var dist = (seg1.position - seg2.position).length()
	var needDist = (seg1.shape.radius+seg2.shape.radius)+0.1
	if dist < needDist:
		return true
	return false
func fix_segments(seg1: CollisionShape2D,seg2: CollisionShape2D):
	var offsetDir = (seg2.position - seg1.position).normalized()
	var offsetDist = (seg2.shape.radius+seg1.shape.radius+0.1)-(seg2.position-seg1.position).length()
	seg2.position += offsetDir*offsetDist

func _draw() -> void:
	for segment: CollisionShape2D in bodySegments:
		if segment.name.contains("segment"):
			draw_circle(segment.position,segment.shape.radius,Color(0,255,0))
		elif segment.name == "head":
			draw_circle(segment.position,segment.shape.radius,Color(255.0,0.0,0.0))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and holding_obj:
		#print('[DEBUG]: MP='+str(event.global_position))
		head.global_position = event.global_position
		changedPosition.emit()
		
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("LMB"):
		holding_obj = !holding_obj
		#print('[DEBUG]: HO='+str(holding_obj))
