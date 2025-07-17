@icon("res://icons/icon_light_bulb.svg")
extends Area3D

@onready var unlit: MeshInstance3D = $Unlit
@onready var lit_beacon: MeshInstance3D = $LitBeacon
@onready var omni_light: OmniLight3D = $OmniLight
@onready var fixture_off: MeshInstance3D = $FixtureOff
@onready var fixture_on: MeshInstance3D = $FixtureOn


var lit := false

func _ready() -> void:
	turn_off()
	if name in Carryovers.lit_torches:
		light_up()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		light_up()

func light_up() -> void:
	#lit_beacon.visible = true
	omni_light.visible = true
	fixture_on.visible = true
	fixture_off.visible = false
	
	if not name in Carryovers.lit_torches:
		Carryovers.lit_torches.append(name)

func turn_off() -> void:
	lit_beacon.visible = false
	omni_light.visible = false
	fixture_on.visible = false
	fixture_off.visible = true
