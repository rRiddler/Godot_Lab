extends CharacterBody2D
@onready var head = $"head"
@onready var bodySegments = find_children("*","CollisionShape2D")
@export var bodySegmentCount: int
@export var headRadius: int
@export var movementSpeed: int
@export var offsetFixingPosition: float
@export_range(0.0,1.0) var segmentSizeDegradationPercent: float 

signal changedPosition
var holding_obj = false

# INITIALIZING OBJECT
func _ready() -> void:
	# Preloading existing nodes - Head
	bodySegments.erase($"head/Area2D/CollisionShape2D")
	var prevSegment = head
	# Begin to generate body based on public attributes. They are "connected" by order of creation
	for i in range(bodySegmentCount):
		prevSegment = add_segment(prevSegment)
	# Trying to reconnect all segments together on loading of scene
	changedPosition.connect(move_segments)
	changedPosition.emit()

# GRAPHICS
# Using process only to redraw body
func _process(delta: float) -> void:
	queue_redraw()
# we only drawing bodyParts with circles which fill whole CollisionShape2D radius
# TODO: move away from CollisionShape2D's to Node2D's - anyway not using integrated collisions
func _draw() -> void:
	for segment: CollisionShape2D in bodySegments:
		if segment.name.contains("segment"):
			draw_circle(segment.position,segment.shape.radius,Color(0,255,0))
		elif segment.name == "head":
			draw_circle(segment.position,segment.shape.radius,Color(255.0,0.0,0.0))

# BRAIN LOGIC
# Main logic behind moving bodyParts around by following Head and moving them away from each other
# by own collission detection
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
	# in next steps first use of prevSegment is a 'Tail' of creature
	var readjust: bool = false
	for i in range(0,bodySegments.size()):
		for j in range(1,bodySegments.size()):
			if (i != bodySegments.size()-1 and do_collide(bodySegments[i],bodySegments[j])):
				fix_segments(bodySegments[i],bodySegments[j])
				readjust = true
			# if currect bodyPart is Tail then we check its collision with Head separately
		if (i == bodySegments.size()-1 and do_collide(bodySegments[0],bodySegments[i]) ):
			fix_segments(bodySegments[0],bodySegments[i])
			readjust = true
	#if readjust:
		#changedPosition.emit()
# base func to decide whether two parts are colliding
func do_collide(seg1: CollisionShape2D,seg2: CollisionShape2D):
	var dist = (seg1.position - seg2.position).length()
	var needDist = (seg1.shape.radius+seg2.shape.radius)+0.1
	if dist < needDist:
		return true
	return false
# base func to move second bodyPart away from first for exact distance 
#	they are colliding with each other
func fix_segments(seg1: CollisionShape2D,seg2: CollisionShape2D):
	var offsetDir = (seg2.position - seg1.position).normalized()
	var offsetDist = (seg2.shape.radius+seg1.shape.radius+offsetFixingPosition)-(seg2.position-seg1.position).length()
	seg2.position += offsetDir*offsetDist
func add_segment(prevSegment: CollisionShape2D):
	var newName = "segment0"
	if prevSegment.name !="head":
		newName = "segment" + str(prevSegment.name.replace("segment","").to_int()+1)
	var newSegment = CollisionShape2D.new()
	newSegment.name = newName
	add_child(newSegment)
	newSegment.shape = CircleShape2D.new()
	newSegment.shape.radius = prevSegment.shape.radius * (1.0-segmentSizeDegradationPercent)
	newSegment.global_position = prevSegment.global_position-Vector2(-1,0)*(prevSegment.shape.radius+newSegment.shape.radius) 
	bodySegments.append(newSegment)
	return newSegment

# INPUT EVENT HANDLING
# functionality to move around grabbed snake head with cursor global positioning
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and holding_obj:
		#print('[DEBUG]: MP='+str(event.global_position))
		head.global_position = event.global_position
		changedPosition.emit()
# funcionality to grab the Head of snake
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("LMB"):
		holding_obj = !holding_obj
		#print('[DEBUG]: HO='+str(holding_obj))
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		head.position.x -= movementSpeed
		changedPosition.emit()
	elif Input.is_action_pressed("ui_right"):
		head.position.x += movementSpeed
		changedPosition.emit()
	if Input.is_action_pressed("ui_up"):
		head.position.y -= movementSpeed
		changedPosition.emit()
	elif Input.is_action_pressed("ui_down"):
		head.position.y += movementSpeed
		changedPosition.emit()
	if Input.is_action_just_pressed("addBodyPart"):
		add_segment(bodySegments[-1])
	
