extends Node3D
# Putting some shit here to make sure it works

@onready var patrol_container: Node3D = $PatrolContainer
@onready var crackhead: CharacterBody3D = $Crackhead
@onready var player_life_timer: Timer = $PlayerLifeTimer
@onready var player: CharacterBody3D = $Player

var patrol_points: Array[Node]

func _ready() -> void:
	FadeTransition.fade_from_black()


func _on_crackhead_get_patrol_points(me: CharacterBody3D) -> void:
	pass


func _on_player_ded() -> void:
	await FadeTransition.fade_to_black(0.8)
	get_tree().reload_current_scene()
