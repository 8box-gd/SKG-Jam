extends Node3D
# Putting some shit here to make sure it works

@onready var patrol_container: Node3D = $PatrolContainer
@onready var crackhead: CharacterBody3D = $Crackhead

var patrol_points: Array[Node]

func _ready() -> void:
	pass


func _on_crackhead_get_patrol_points(me: CharacterBody3D) -> void:
	pass
