@icon("res://icons/icon_light_bulb.svg")
extends Area3D

@onready var omni_light: OmniLight3D = $OmniLight
@onready var fixture_off: MeshInstance3D = $FixtureOff
@onready var fixture_on: MeshInstance3D = $FixtureOn
@onready var lightswitch: AudioStreamPlayer3D = $Lightswitch

var lit := false

func _ready() -> void:
	turn_off()
	if name in Carryovers.lit_torches:
		light_up()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not lit:
		lightswitch.play() # Only play if just turned on, not on scene start
		light_up()

func light_up() -> void:
	#lit_beacon.visible = true
	lit = true
	omni_light.visible = true
	fixture_on.visible = true
	fixture_off.visible = false
	
	if not name in Carryovers.lit_torches:
		Carryovers.lit_torches.append(name)
		#print("Torches found: ", Carryovers.lit_torches.size())S

func turn_off() -> void:
	lit = false
	omni_light.visible = false
	fixture_on.visible = false
	fixture_off.visible = true
