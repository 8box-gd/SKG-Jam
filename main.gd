extends Node3D
# Putting some shit here to make sure it works

@onready var patrol_container: Node3D = $PatrolContainer
@onready var crackhead: CharacterBody3D = $Crackhead
@onready var player_life_timer: Timer = $PlayerLifeTimer
@onready var player: Player = $Player
@onready var exit_door: Node3D = $ExitDoor
@onready var end_light: OmniLight3D = $EndingTrigger/EndLight
@onready var end_light_sound: AudioStreamPlayer3D = $EndingTrigger/EndLightSound

var reached_ending := false

var patrol_points: Array[Node]

func _ready() -> void:
	FadeTransition.fade_from_black()
	Carryovers.run_counter += 1

func _on_crackhead_get_patrol_points(me: CharacterBody3D) -> void:
	pass

func _on_player_ded() -> void:
	await FadeTransition.fade_to_black(0.8)
	get_tree().change_scene_to_file("res://between_rounds.tscn")


func _on_ending_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not reached_ending:
		start_ending()

func start_ending() -> void:
	print("Starting ending")
	reached_ending = true
	player.life_timer.paused = true
	player.ten_second_warning.paused = true
	player.heartbeat_sound.stop()
	exit_door.slam_shut()
	crackhead.queue_free()
	await get_tree().create_timer(1.0).timeout
	end_light.visible = true
	end_light_sound.play()
	player.ending_text()


func _on_player_to_credits() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")
