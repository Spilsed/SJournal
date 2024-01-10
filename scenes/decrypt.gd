extends Control

@onready var password: LineEdit = $VBoxContainer/Password
@onready var confirm_password: LineEdit = $VBoxContainer/ConfirmPassword
@onready var error_label: Label = $VBoxContainer/Error

func _ready():
	if !Globals.data_exists():
		print("AER")
		confirm_password.show()
	print("eawse")

func _on_password_text_submitted(new_text):
	if confirm_password.visible and password.text != confirm_password.text:
		error_label.text = "Passwords don't match"
		return
	
	Globals.key = new_text
	if Globals.attempt_init_decrypt():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		error_label.text = "Wrong password"
