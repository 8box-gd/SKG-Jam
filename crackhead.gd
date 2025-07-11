extends CharacterBody3D

enum {WANDERING, TRACKING, WINDUP, CHARGE, BONK, STAB}
@onready var hearing_cast: RayCast3D = $HearingCast
@onready var charge_cast: RayCast3D = $ChargeCast

@export var player: CharacterBody3D

@export var charge_speed := 20.0
@export var charge_accel := 25.0

var move_dir := Vector3.FORWARD
var state := TRACKING
var last_known_player_position := Vector3.ZERO

func _ready() -> void:
	if player: player.footstep.connect(on_player_footstep)

func _physics_process(delta: float) -> void:
	if player:
		hearing_cast.look_at(player.global_position + Vector3(0,1,0))
		charge_cast.look_at(player.global_position + Vector3(0,1,0))
	
	match state:
		TRACKING: tracking_state(delta)
		CHARGE: charge_state(delta)
		_: pass

func tracking_state(delta: float) -> void:
	if charge_cast.is_colliding(): # If you get too close, he auto-charges regardless of sneak
		if charge_cast.get_collider().is_in_group("Player"):
			move_dir = to_local(player.global_position)
			move_dir = move_dir.normalized()
			state = CHARGE

func charge_state(delta: float) -> void:
	velocity = velocity.move_toward(move_dir * charge_speed, charge_accel * delta)
	move_and_slide()
	

func on_player_footstep():
	match state:
		TRACKING: 
			if hearing_cast.is_colliding():
				if hearing_cast.get_collider().is_in_group("Player"): # Line of sight w Player
					move_dir = to_local(player.global_position)
					move_dir = move_dir.normalized()
					state = CHARGE
				else: # No line of sight
					last_known_player_position = player.global_position
		CHARGE: pass # Unaffected by footsteps
		_: pass
