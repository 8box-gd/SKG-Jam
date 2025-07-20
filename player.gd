class_name Player extends CharacterBody3D

@onready var cam_pivot: Marker3D = $CamPivot
@onready var camera: Camera3D = %Camera3D
@onready var debug_cap: MeshInstance3D = $DebugCap
@onready var step_timer: Timer = $StepTimer
@onready var model: Node3D = %JournalistModel
@onready var anim_player: AnimationPlayer = $JournalistModel/GameRig/AnimationPlayer
@onready var life_timer: Timer = $LifeTimer
@onready var time_label: Label = %TimeLabel
@onready var keypad_ui: Node2D = %KeypadUI
@onready var objective_label: Label = %ObjectiveLabel
@onready var ten_second_warning: Timer = $"10SecondWarning"
@onready var vignette_rect: ColorRect = $CanvasLayer/VignetteRect
@onready var secondary_anim: AnimationPlayer = $SecondaryAnim

@onready var footstep_sound: AudioStreamPlayer3D = $Footsteps
@onready var death_sound: AudioStreamPlayer3D = $Death
@onready var heartbeat_sound: AudioStreamPlayer3D = $Heartbeat

signal footstep
signal ded

@export_group("Params")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 1.0) var y_axis_sensitivity := 1.0
@export var keypad_object: Node3D
@export var move_speed := 8.0
@export var sneak_speed := 4.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0
@export_range(1.0, 120.0, 0.1, "suffix:s") var life_time := 20.0 #[s]

var _cam_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.FORWARD
var sneaking := false
var current_speed := 8.0
var has_control := false # Will be set to False when finished. Left True for debug
var dead := false

func _ready() -> void:
	life_timer.wait_time = life_time
	ten_second_warning.wait_time = life_time - 10.0
	current_speed = move_speed
	#vignette_rect.material.set_shader_parameter("vignette_strength", 0.5)
	if Carryovers.found_keypad or Carryovers.objectives_found > 0:
		update_objective()
	
	# WAKE UP JEFF
	anim_player.play("GetUp/mixamo_com", -1, 1.1)
	await anim_player.animation_finished
	if not dead:
		has_control = true
		life_timer.start()
		ten_second_warning.start()
	
	

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
	cam_pivot.rotation.x -= _cam_input_direction.y * y_axis_sensitivity * delta 
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
		footstep_sound.play()
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
	anim_player.play("NewDeath/mixamo_com")
	heartbeat_sound.stop()
	death_sound.play()
	await anim_player.animation_finished
	ded.emit()

func _on_keypad_show_keypad() -> void:
	print("Player: Got here")
	keypad_ui.start_keypad()

func _on_keypad_hide_keypad() -> void:
	keypad_ui.leave_keypad()

func start_keypad() -> void:
	#print("Player: Got here")
	keypad_ui.start_keypad()

func leave_keypad() -> void:
	#print("Player: Got here")
	keypad_ui.leave_keypad()


func _on_keypad_ui_keypad_solved() -> void:
	print("Player: Keypad solved")
	keypad_object.open_door()

func update_objective() -> void:
	if Carryovers.found_keypad:
		objective_label.text = "Digits found: " + str(Carryovers.objectives_found) + "/6"
	else: 
		objective_label.text = "Digits found: " + str(Carryovers.objectives_found)

func _on_second_warning_timeout() -> void:
	heartbeat_sound.play()
	tween_vignette()

func tween_vignette() -> void:
	secondary_anim.play("VignetteFadeIn")
	#var vintween := Tween.new().set_trans(Tween.TRANS_LINEAR)
	#vintween.tween_property(vignette_rect, "material:shader_parameter/vignette_strength", 1.0, 10.0)
	#vintween.tween_method(func(val:float): vignette_rect.material.set_shader_parameter("vignette_strength", val), 0.0, 1.0, 10.0)
