extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func fade_from_black(spd:float = 1.0):
	visible = true
	anim_player.speed_scale = spd
	anim_player.play("fade_from_black")
	await anim_player.animation_finished
	visible = false

func fade_to_black(spd:float = 1.0):
	visible = true
	anim_player.speed_scale = spd
	anim_player.play("fade_to_black")
	await anim_player.animation_finished
	#visible = false
