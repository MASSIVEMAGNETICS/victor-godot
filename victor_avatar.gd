extends Node2D
class_name VictorAvatar

## Victor Avatar - An animated character with real-time lip-sync capabilities

@onready var lip_sync: LipSyncAnalyzer = $LipSyncAnalyzer

# Visual components (created dynamically)
var head: Polygon2D
var mouth: Polygon2D
var left_eye: Polygon2D
var right_eye: Polygon2D

# Mouth shapes for different visemes
var mouth_shapes = {
	"silent": PackedVector2Array([
		Vector2(-15, 0), Vector2(15, 0), Vector2(10, 2), Vector2(-10, 2)
	]),
	"aa": PackedVector2Array([  # "ah" - wide open
		Vector2(-20, -5), Vector2(20, -5), Vector2(15, 20), Vector2(-15, 20)
	]),
	"ee": PackedVector2Array([  # "ee" - wide smile
		Vector2(-25, 0), Vector2(25, 0), Vector2(20, 5), Vector2(-20, 5)
	]),
	"oh": PackedVector2Array([  # "oh" - rounded
		Vector2(-12, -10), Vector2(12, -10), Vector2(12, 10), Vector2(-12, 10)
	]),
	"uw": PackedVector2Array([  # "oo" - small rounded
		Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)
	]),
	"mm": PackedVector2Array([  # "mm" - lips together
		Vector2(-18, 0), Vector2(18, 0), Vector2(15, 3), Vector2(-15, 3)
	]),
	"ff": PackedVector2Array([  # "ff" - lips and teeth
		Vector2(-16, -2), Vector2(16, -2), Vector2(14, 6), Vector2(-14, 6)
	]),
	"th": PackedVector2Array([  # "th" - tongue visible
		Vector2(-18, 0), Vector2(18, 0), Vector2(16, 8), Vector2(-16, 8)
	]),
	"ss": PackedVector2Array([  # "ss" - tight
		Vector2(-20, 0), Vector2(20, 0), Vector2(18, 4), Vector2(-18, 4)
	])
}

# Animation parameters
var current_mouth_shape: PackedVector2Array
var target_mouth_shape: PackedVector2Array
var morph_speed: float = 10.0

# Blink animation
var blink_timer: float = 0.0
var blink_interval: float = 3.0
var is_blinking: bool = false
var blink_duration: float = 0.15

func _ready():
	create_visual_components()
	
	# Set initial mouth shape
	current_mouth_shape = mouth_shapes["silent"]
	target_mouth_shape = current_mouth_shape
	update_mouth()
	
	# Connect to lip sync analyzer
	if lip_sync:
		lip_sync.viseme_changed.connect(_on_viseme_changed)
	
	# Start blink timer
	blink_timer = randf_range(2.0, 4.0)

func create_visual_components():
	# Create head (circular)
	if not head:
		head = Polygon2D.new()
		add_child(head)
		head.name = "Head"
	
	var head_points = PackedVector2Array()
	var segments = 32
	var radius = 80
	for i in range(segments):
		var angle = (2.0 * PI * i) / segments
		head_points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	
	head.polygon = head_points
	head.color = Color(0.95, 0.8, 0.7)  # Skin tone
	head.position = Vector2(640, 300)
	
	# Create eyes
	if not left_eye:
		left_eye = Polygon2D.new()
		head.add_child(left_eye)
		left_eye.name = "LeftEye"
	
	if not right_eye:
		right_eye = Polygon2D.new()
		head.add_child(right_eye)
		right_eye.name = "RightEye"
	
	var eye_points = PackedVector2Array([
		Vector2(-8, -12), Vector2(8, -12), Vector2(8, 12), Vector2(-8, 12)
	])
	
	left_eye.polygon = eye_points
	left_eye.color = Color(0.1, 0.1, 0.1)
	left_eye.position = Vector2(-30, -20)
	
	right_eye.polygon = eye_points
	right_eye.color = Color(0.1, 0.1, 0.1)
	right_eye.position = Vector2(30, -20)
	
	# Create mouth
	if not mouth:
		mouth = Polygon2D.new()
		head.add_child(mouth)
		mouth.name = "Mouth"
	
	mouth.color = Color(0.8, 0.3, 0.3)
	mouth.position = Vector2(0, 30)

func _process(delta):
	# Animate mouth morphing
	animate_mouth(delta)
	
	# Handle blinking
	handle_blinking(delta)

func animate_mouth(delta):
	# Smoothly interpolate between current and target mouth shape
	if current_mouth_shape.size() != target_mouth_shape.size():
		current_mouth_shape = target_mouth_shape
	
	var all_close_enough = true
	for i in range(current_mouth_shape.size()):
		if current_mouth_shape[i].distance_to(target_mouth_shape[i]) > 0.5:
			all_close_enough = false
			current_mouth_shape[i] = current_mouth_shape[i].lerp(
				target_mouth_shape[i], 
				morph_speed * delta
			)
	
	if not all_close_enough:
		update_mouth()

func update_mouth():
	if mouth and current_mouth_shape.size() > 0:
		mouth.polygon = current_mouth_shape

func handle_blinking(delta):
	blink_timer -= delta
	
	if blink_timer <= 0:
		# Start blinking
		if not is_blinking:
			is_blinking = true
			close_eyes()
			blink_timer = blink_duration
		else:
			# Finish blinking
			is_blinking = false
			open_eyes()
			blink_timer = randf_range(2.0, 5.0)

func close_eyes():
	if left_eye and right_eye:
		var closed_eye = PackedVector2Array([
			Vector2(-8, 0), Vector2(8, 0), Vector2(8, 2), Vector2(-8, 2)
		])
		left_eye.polygon = closed_eye
		right_eye.polygon = closed_eye

func open_eyes():
	if left_eye and right_eye:
		var open_eye = PackedVector2Array([
			Vector2(-8, -12), Vector2(8, -12), Vector2(8, 12), Vector2(-8, 12)
		])
		left_eye.polygon = open_eye
		right_eye.polygon = open_eye

func _on_viseme_changed(viseme: String):
	# Update target mouth shape based on viseme
	if mouth_shapes.has(viseme):
		target_mouth_shape = mouth_shapes[viseme]
	else:
		target_mouth_shape = mouth_shapes["silent"]

func set_viseme(viseme: String):
	_on_viseme_changed(viseme)
