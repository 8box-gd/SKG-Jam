extends CharacterBody3D

enum {WANDERING, TRACKING, WINDUP, CHARGE, BONK, STAB}
@onready var hearing_cast: RayCast3D = %HearingCast
@onready var charge_cast: RayCast3D = %ChargeCast
@onready var hearing_range: Area3D = $HearingRange # If you're in this sphere, he can hear you
@onready var last_pos_indicator: MeshInstance3D = $LastPosIndicator
@onready var wallhack_cast: RayCast3D = %WallhackCast
@onready var raycast_origin: Marker3D = $RaycastOrigin
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var bonk_recovery_timer: Timer = $BonkRecoveryTimer
@onready var debug_cap: MeshInstance3D = $DebugCap
@onready var charge_collision: Area3D = $ChargeCollision

@export var player: CharacterBody3D
@export var tracking_speed := 4.0
@export var tracking_accel := 8.0
@export var charge_speed := 20.0
@export var charge_accel := 20.0
@export var rotation_speed := 10.0

var move_dir := Vector3.FORWARD
var state := TRACKING
var last_known_player_position := Vector3.ZERO

func _ready() -> void:
	if player:
		player.footstep.connect(on_player_footstep)
		update_player_pos()

func _physics_process(delta: float) -> void:
	if player:
		raycast_origin.look_at(player.global_position + Vector3(0,1,0))
		if state != CHARGE:
			charge_collision.look_at(player.global_position + Vector3(0,1,0))
			charge_collision.rotation.x = 0.0
			charge_collision.rotation.z = 0.0
	
	match state:
		TRACKING: tracking_state(delta)
		CHARGE: charge_state(delta)
		BONK: bonk_state(delta)
		_: pass
	
	if state != BONK:
		var target_angle := Vector3.FORWARD.signed_angle_to(velocity, Vector3.UP)
		debug_cap.global_rotation.y = lerp_angle(debug_cap.rotation.y, target_angle, rotation_speed * delta)

func tracking_state(delta: float) -> void:
	var nav_direction := Vector3.ZERO
	
	nav_direction = nav_agent.get_next_path_position() - global_position
	nav_direction = nav_direction.normalized()
	velocity = velocity.move_toward(nav_direction * tracking_speed, tracking_accel * delta)
	move_and_slide()
	
	if charge_cast.is_colliding(): # If you get too close, he auto-charges regardless of sneak
		if charge_cast.get_collider().is_in_group("Player"):
			update_player_pos()
			move_dir = to_local(player.global_position + Vector3(0,1,0))
			move_dir = move_dir.normalized()
			state = CHARGE

func charge_state(delta: float) -> void:
	velocity = velocity.move_toward(move_dir * charge_speed, charge_accel * delta)
	move_and_slide()

func bonk_state(delta: float) -> void: #Transition out of BONK is done by timer
	move_dir = -move_dir
	velocity = velocity.move_toward(Vector3.ZERO, charge_accel * delta)
	move_and_slide()
	

func _on_bonk_recovery_timer_timeout() -> void:
	state = TRACKING

func on_player_footstep():
	match state:
		TRACKING: 
			# Since hearing_cast can still touch walls if youre out of range
			if hearing_cast.is_colliding() and wallhack_cast.is_colliding():
				if hearing_cast.get_collider().is_in_group("Player"): # Line of sight w Player
					update_player_pos()
					move_dir = to_local(player.global_position)
					move_dir = move_dir.normalized()
					state = CHARGE
				else: # No line of sight
					update_player_pos()
		CHARGE: pass # Unaffected by footsteps
		_: pass

func update_player_pos() -> void:
	last_known_player_position = player.global_position
	last_pos_indicator.global_position = last_known_player_position
	nav_agent.target_position = last_known_player_position # Here so it doesnt update every frame

# CHARGE -> BONK transition happens here
func _on_charge_collision_body_entered(body: Node3D) -> void:
	if body == self: return
	if state != CHARGE: return
	velocity = -velocity * 0.3
	bonk_recovery_timer.start()
	state = BONK
