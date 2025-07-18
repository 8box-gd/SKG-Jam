@icon("res://icons/icon_skull.svg")
extends CharacterBody3D

enum {TRACKING, CHARGE, BONK, RUSH, KILL}
@onready var hearing_cast: RayCast3D = %HearingCast
@onready var charge_cast: RayCast3D = %ChargeCast
@onready var hearing_range_shape: CollisionShape3D = $HearingRange/CollisionShape3D # For debug purposes
@onready var last_pos_indicator: MeshInstance3D = $LastPosIndicator
@onready var wallhack_cast: RayCast3D = %WallhackCast
@onready var raycast_origin: Marker3D = $RaycastOrigin
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var bonk_recovery_timer: Timer = $BonkRecoveryTimer
@onready var debug_cap: MeshInstance3D = $DebugCap
@onready var charge_collision: Area3D = $ChargeCollision
@onready var charge_cooldown: Timer = $ChargeCooldown

signal get_patrol_points(me: CharacterBody3D)

@export_group("Siblings")
@export var player: CharacterBody3D
@export var points_contaner: Node3D
@export var objective_container: Node3D
@export_group("Movement")
@export var hearing_range := 12.0 #[m] Radius
@export var autocharge_range := 2.0 #[m] Also a radius
@export var tracking_speed := 4.0
@export var tracking_accel := 8.0
@export var charge_speed := 20.0
@export var charge_accel := 20.0
@export var rush_speed := 8.0
@export var rush_accel := 12.0
@export var rotation_speed := 10.0
@export var search_precision := 3.0 #[m]

var move_dir := Vector3.FORWARD
var state := TRACKING
var last_known_player_position := Vector3.ZERO
var patrol_points: Array[Node]

func _ready() -> void:
	# Set hearing and autocharge ranges
	hearing_cast.target_position.z = -hearing_range
	wallhack_cast.target_position.z = -hearing_range
	charge_cast.target_position.z = -autocharge_range
	hearing_range_shape.get_shape().radius = hearing_range
	
	if player:
		player.footstep.connect(on_player_footstep)
		update_player_pos()
	if points_contaner:
		patrol_points = points_contaner.child_array
		#print("Patrol points attained: ", patrol_points)
	else:
		print("Crackhead: Patrol points not found")
	
	# Spawn at random objective
	# Wait to teleport in, to allow player wakeup animation to pass
	# When not debugging, move Crackhead outside of the map
	await get_tree().create_timer(3.0).timeout
	global_position = objective_container.get_children().pick_random().global_position

func _physics_process(delta: float) -> void:
	if player:
		raycast_origin.look_at(player.global_position + Vector3(0,1,0))
		if state != CHARGE:
			charge_collision.look_at(player.global_position + Vector3(0,1,0))
			charge_collision.rotation.x = 0.0
			charge_collision.rotation.z = 0.0
	
	# Gravity should affect it regardless of state
	
	match state:
		TRACKING: tracking_state(delta)
		CHARGE: charge_state(delta)
		BONK: bonk_state(delta)
		RUSH: rush_state(delta)
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
	
	if global_position.distance_to(last_known_player_position) < search_precision:
		find_patrol_point()
	
	if charge_cast.is_colliding(): # If you get too close, he auto-charges regardless of sneak
		if charge_cast.get_collider().is_in_group("Player"):
			update_player_pos()
			move_dir = to_local(player.global_position + Vector3(0,1,0))
			move_dir.y = 0.0
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
	charge_cooldown.start()

func on_player_footstep():
	match state:
		TRACKING: 
			# Since hearing_cast can still touch walls if youre out of range
			if hearing_cast.is_colliding() and wallhack_cast.is_colliding():
				if hearing_cast.get_collider().is_in_group("Player") and charge_cooldown.time_left == 0.0: # Line of sight w Player
					update_player_pos()
					move_dir = to_local(player.global_position)
					move_dir = move_dir.normalized()
					state = CHARGE
				else: # No line of sight, track behind wall
					update_player_pos()
		RUSH:
			if hearing_cast.is_colliding() and wallhack_cast.is_colliding():
				state = TRACKING
				print("Rush ended")
		CHARGE: pass # Unaffected by footsteps
		_: pass

func update_player_pos() -> void:
	last_known_player_position = player.global_position
	last_pos_indicator.global_position = last_known_player_position
	nav_agent.target_position = last_known_player_position # Here so it doesnt update every frame

func find_patrol_point() -> void:
	#print("Picking random patrol point")
	last_known_player_position = patrol_points.pick_random().global_position
	last_pos_indicator.global_position = last_known_player_position
	nav_agent.target_position = last_known_player_position

# CHARGE -> BONK transition happens here
func _on_charge_collision_body_entered(body: Node3D) -> void:
	if body == self: return
	if state != CHARGE: return
	if body.is_in_group("Player"):
		player.die()
		return
	velocity = -velocity * 0.3
	bonk_recovery_timer.start()
	state = BONK

# Identical to TRACKING but faster
func rush_state(delta) -> void:
	var nav_direction := Vector3.ZERO
	
	nav_direction = nav_agent.get_next_path_position() - global_position
	nav_direction = nav_direction.normalized()
	velocity = velocity.move_toward(nav_direction * rush_speed, rush_accel * delta)
	move_and_slide()
	
	if global_position.distance_to(last_known_player_position) < search_precision:
		find_patrol_point()
	
	if charge_cast.is_colliding(): # If you get too close, he auto-charges regardless of sneak
		if charge_cast.get_collider().is_in_group("Player"):
			update_player_pos()
			move_dir = to_local(player.global_position + Vector3(0,1,0))
			move_dir.y = 0.0
			move_dir = move_dir.normalized()
			state = CHARGE

func trigger_rush() -> void:
	if state == TRACKING:
		update_player_pos()
		state = RUSH
		print("Rush started")
