extends Node3D

@export var dot: PackedScene
@export var frames: int
@export var fps: int
@export var sphere: Node3D
@export var cube: Node3D

var animation = []
var currentFrame = 0
var timeUntilNextFrame = 0

func previousFrame():
	if currentFrame > 0:
		return currentFrame - 1
	else:
		return frames - 1

func get_circle_func(radius: float):
	return func(x: float) -> Vector3:
		return Vector3(cos(x * PI * 2), 0, sin(x * PI * 2)) * radius
		
func get_half_circle_func(radius: float):
	return func(x: float) -> Vector3:
		return Vector3(cos(x * PI), 0, sin(x * PI)) * radius
		
func get_line_func(radius: float):
	return func(x: float) -> Vector3:
		return Vector3(1.0 - x * 2, 0, 0) * radius

func get_dot_func(radius: float):
	return func(x: float) -> Vector3:
		return Vector3()

func get_interpolated_func(func1, func2, w):
	return func(x: float) -> Vector3:
		return func1.call(x).lerp(func2.call(x), w)

func redo_animation(f):
	for n in sphere.get_children():
		sphere.remove_child(n)
		n.queue_free()
	animation = []
	
	for i in range(frames):
		var frac = i as float / frames
		var pos = f.call(frac)
		var instance = dot.instantiate()
		instance.position = pos
		instance.material_override = StandardMaterial3D.new()
		instance.material_override.albedo_color = Color(1, 0, 0, 0.3)
		sphere.add_child(instance)
		animation.append([pos, instance])

var animators = [
	func(i): return get_interpolated_func(get_circle_func(1), get_dot_func(1), i),
	func(i): return get_interpolated_func(get_half_circle_func(1), get_line_func(1), i)
]
var current_animator = 0

var interpolation = 0.0
var epsilon = 0.0001
func _ready():
	redo_animation(animators[current_animator].call(interpolation))
	
func _input(ev):
	if Input.is_key_pressed(KEY_UP):
		if (interpolation < 1 - epsilon):
			interpolation += 0.1
	if Input.is_key_pressed(KEY_DOWN):
		if (interpolation > 0 + epsilon):
			interpolation -= 0.1
	if Input.is_key_pressed(KEY_LEFT):
		current_animator += animators.size() - 1
		current_animator %= animators.size()
	if Input.is_key_pressed(KEY_RIGHT):
		current_animator += 1
		current_animator %= animators.size()
	print(interpolation)
	redo_animation(animators[current_animator].call(interpolation))

func _process(delta):
	if (timeUntilNextFrame > 0):
		timeUntilNextFrame -= delta
	timeUntilNextFrame += 1 / fps as float
	
	animation[previousFrame()][1].material_override.albedo_color = Color(1, 0, 0, 0.3)
	animation[currentFrame][1].material_override.albedo_color = Color(0, 1, 0, 0.3)
	
	currentFrame += 1
	currentFrame %= frames
	
	var angle = animation[currentFrame][0].length() * PI
	var axis = animation[currentFrame][0].normalized()
	
	cube.quaternion = Quaternion(axis, angle)
	#cube.rotation = Vector3()
	#cube.rotate_object_local(axis, angle)
	
	pass
