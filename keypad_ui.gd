extends Node2D

@onready var keypad_sprite: Sprite2D = $KeypadSprite
@onready var remembered_label: RichTextLabel = $RememberedLabel
@onready var input_label: Label = $InputLabel
@onready var help_label: Label = $HelpLabel
@onready var beep_sound: AudioStreamPlayer2D = $Beep
@onready var wrong_sound: AudioStreamPlayer2D = $Wrong
@onready var right_sound: AudioStreamPlayer2D = $Right
@onready var easter_egg: RichTextLabel = $EasterEgg
signal keypad_solved

var displayed_numbers := ""
var remembered_numbers := ""
var active := false
var solved := false

var bbcode_prefix := "[font_size=40][color=MEDIUM_ORCHID][shake rate=20.0 level=5 connected=1]"

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if not active: return
	if displayed_numbers.length() == 6: return
	# If I knew how to make this into a match statement, I would.
	if event.is_action_pressed("one"):
		displayed_numbers += "1"
		beep_sound.play()
	if event.is_action_pressed("two"):
		displayed_numbers += "2"
		beep_sound.play()
	if event.is_action_pressed("three"):
		displayed_numbers += "3"
		beep_sound.play()
	if event.is_action_pressed("four"):
		displayed_numbers += "4"
		beep_sound.play()
	if event.is_action_pressed("five"):
		displayed_numbers += "5"
		beep_sound.play()
	if event.is_action_pressed("six"):
		displayed_numbers += "6"
		beep_sound.play()
	if event.is_action_pressed("seven"):
		displayed_numbers += "7"
		beep_sound.play()
	if event.is_action_pressed("eight"):
		displayed_numbers += "8"
		beep_sound.play()
	if event.is_action_pressed("nine"):
		displayed_numbers += "9"
		beep_sound.play()
	if event.is_action_pressed("zero"):
		displayed_numbers += "0"
		beep_sound.play()
	
	if event.is_action_pressed("ui_cancel"):
		help_label.visible = true
	
	
	
	input_label.text = displayed_numbers
	if displayed_numbers.length() == 6:
		if displayed_numbers == Carryovers.door_code:
			code_correct()
		else:
			code_incorrect()

func reset_keypad() -> void:
	displayed_numbers = ""
	input_label.text = displayed_numbers
	input_label.label_settings.font_color = Color(1,1,1)

func start_keypad() -> void:
	reset_keypad()
	update_remembered_digits()
	if not solved:
		visible = true
	else:
		print("Keypad stays hidden since its solved")
	active = true

func leave_keypad() -> void:
	reset_keypad()
	visible = false
	active = false

func update_remembered_digits() -> void:
	remembered_label.text = bbcode_prefix
	remembered_numbers = ""
	for i in Carryovers.objectives_found:
		remembered_numbers += Carryovers.door_code[i]
	remembered_label.text += remembered_numbers

func code_correct() -> void:
	print("Code correct!")
	right_sound.play()
	input_label.label_settings.font_color = Color(0,1,0)
	solved = true
	keypad_solved.emit()

func code_incorrect() -> void:
	# Easter egg will only trigger if it is NOT the randomly chosen code.
	# There is a 1 in 1 million chance for this
	# Chosen code: Rescue has had 70 total ferrets
	if displayed_numbers == "707070":
		show_easteregg()
	
	print("Code incorrect.")
	wrong_sound.play()
	input_label.label_settings.font_color = Color(1,0,0)
	await get_tree().create_timer(1.0).timeout
	reset_keypad()

func show_easteregg():
	easter_egg.visible = true
	await get_tree().create_timer(5.0).timeout
	easter_egg.visible = false
