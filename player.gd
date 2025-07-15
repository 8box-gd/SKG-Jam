extends CharacterBody3D

@onready var cam_pivot: Marker3D = $CamPivot
@onready var camera: Camera3D = %Camera3D
@onready var debug_cap: MeshInstance3D = $DebugCap
@onready var step_timer: Timer = $StepTimer
@onready var model: Node3D = %JournalistModel
@onready var anim_player: AnimationPlayer = $JournalistModel/GameRig/AnimationPlayer
@onready var life_timer: Timer = $LifeTimer
@onready var time_label: Label = $TimeLabel

signal footstep
signal ded

@export_group("Params")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 1.0) var y_axis_sensitivity := 1.0
@export var move_speed := 8.0
@export var sneak_speed := 4.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0

var _cam_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.FORWARD
var sneaking := false
var current_speed := 8.0
var has_control := true # Will be set to False when finished. Left True for debug
var dead := false

func _ready() -> void:
	current_speed = move_speed
	
	# WAKE UP JEFF
	anim_player.play("GetUp/mixamo_com")
	await anim_player.animation_finished
	if not dead: has_control = true

# Capturing an uncapturing the mouse
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Mouse movement
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	if is_camera_motion:
		_cam_input_direction = event.screen_relative * mouse_sensitivity

# Negative Z is forward
func _physics_process(delta: float) -> void:
	# Camera handlng
	cam_pivot.rotation.x += _cam_input_direction.y * y_axis_sensitivity * delta 
	cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, -PI/4.0, PI/6.0)
	cam_pivot.rotation.y -= _cam_input_direction.x * delta
	_cam_input_direction = Vector2.ZERO
	
	var raw_input := Vector2.ZERO
	if has_control:
		raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x
	
	# Sneak handling
	if Input.is_action_pressed("sneak"):
		sneaking = true
		current_speed = sneak_speed
	else:
		sneaking = false
		current_speed = move_speed
	
	var move_dir := forward * raw_input.y + right * raw_input.x
	move_dir.y = 0.0
	move_dir = move_dir.normalized()
	velocity = velocity.move_toward(move_dir * current_speed, acceleration * delta)
	
	if is_equal_approx(move_dir.length(), 0.0) and velocity.length() < stopping_speed:
		velocity = Vector3.ZERO
	
	if move_dir.length() > 0.2:
		_last_movement_direction = move_dir
	var target_angle := Vector3.FORWARD.signed_angle_to(_last_movement_direction, Vector3.UP)
	debug_cap.global_rotation.y = lerp_angle(debug_cap.rotation.y, target_angle, rotation_speed * delta)
	model.global_rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
	
	move_and_slide()
	
	# Footstep handling
	if raw_input != Vector2.ZERO and step_timer.time_left == 0.0 and not sneaking:
		footstep.emit()
		step_timer.start()
	
	if has_control: handle_animations()
	
	time_label.text = str(int(life_timer.time_left))

func handle_animations() -> void:
	if sneaking:
		if velocity.length() > 0: anim_player.play("SneakWalk/mixamo_com")
		else: anim_player.play("CrouchIdle/mixamo_com")
	elif velocity.length() > 0: anim_player.play("run-anim/mixamo_com")
	else: anim_player.play("Idle/mixamo_com")

func _on_life_timer_timeout() -> void:
	die()

func die() -> void:
	if dead: return
	dead = true
	velocity = Vector3.ZERO
	has_control = false
	anim_player.play("FallFlat/mixamo_com")
	await anim_player.animation_finished
	ded.emit()
