@icon("res://icons/icon_parchment.svg")
extends Area3D
@onready var page_flip: AudioStreamPlayer3D = $PageFlip

signal objective_found

@export var player: CharacterBody3D

func _ready() -> void:
	if name in Carryovers.found_objectives_list:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		find_objective()
		

func find_objective() -> void:
	if not name in Carryovers.found_objectives_list:
		Carryovers.found_objectives_list.append(name)
		objective_found.emit()
		Carryovers.objectives_found += 1
		player.update_objective()
		visible = false
		page_flip.play()
		await page_flip.finished
		queue_free()
