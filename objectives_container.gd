@icon("res://icons/icon_parchment.svg")
extends Node3D

@export var crackhead: CharacterBody3D
var objective_list: Array[Node]

# This will signal Crackhead that the objective was found
func _ready():
	objective_list = get_children()
	for obj:Area3D in objective_list:
		obj.objective_found.connect(_on_objective_found)

func _on_objective_found():
	crackhead.trigger_rush()
