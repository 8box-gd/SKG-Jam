extends CharacterBody3D

@onready var cam_pivot: Marker3D = $CamPivot
@onready var camera: Camera3D = $CamPivot/Camera3D
@onready var debug_cap: MeshInstance3D = $DebugCap

@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0

var _cam_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK

# Postive Z is forward (right), camera located on Negative X Axis
func _physics_process(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x
	
	var move_dir := forward * raw_input.y + right * raw_input.x
	move_dir.y = 0.0
	move_dir = move_dir.normalized()
	var y_velocity := velocity.y
	velocity = velocity.move_toward(move_dir * move_speed, acceleration * delta)
	
	if is_equal_approx(move_dir.length(), 0.0) and velocity.length() < stopping_speed:
		velocity = Vector3.ZERO
	
	if move_dir.length() > 0.2:
		_last_movement_direction = move_dir
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	debug_cap.global_rotation.y = lerp_angle(debug_cap.rotation.y, target_angle, rotation_speed * delta)
	
	move_and_slide()
