extends Area3D

@onready var unlit: MeshInstance3D = $Unlit
@onready var lit_beacon: MeshInstance3D = $LitBeacon

var lit := false

func _ready() -> void:
	turn_off()
	if name in Carryovers.lit_torches:
		light_up()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		light_up()

func light_up() -> void:
	lit_beacon.visible = true
	if not name in Carryovers.lit_torches:
		Carryovers.lit_torches.append(name)

func turn_off() -> void:
	lit_beacon.visible = false
