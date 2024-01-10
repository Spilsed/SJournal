class_name Page extends Control

var id: int = 100
var creation_date: int

var data: Dictionary = {"title": "", "body_text": ""}

@onready var body_text: TextEdit = $VBoxContainer/BodyText
@onready var title_text: LineEdit = $VBoxContainer/TitleEdit

func setup(id: int = Globals.journal_data.size(), _creation_date: int = Time.get_unix_time_from_system()):
	self.id = id
	self.creation_date = creation_date
	load_page()

func save_page() -> void:
	add_page_check()
	
	var file: FileAccess = FileAccess.open(Globals.save_path+Globals.journal_data[id]["file_name"], FileAccess.WRITE)
	file.store_var(Globals.aes_encrypt(Globals.dict_to_bytes(data)))

func load_page() -> bool:
	if id < 0 or id >= Globals.journal_data.size():
		return false
	
	var file: FileAccess = FileAccess.open(Globals.save_path+Globals.journal_data[id]["file_name"], FileAccess.READ)
	var file_dat = file.get_var()
	data = Globals.bytes_to_dict(Globals.aes_decrypt(file_dat))
	Globals.json.data = ""
	
	title_text.text = data["title"]
	body_text.text = data["body_text"]
	
	return true

func _on_title_edit_text_submitted(new_text):
	add_page_check()
	
	data["title"] = new_text
	Globals.journal_data[id]["public_title"] = new_text

func _on_body_text_text_changed():
	add_page_check()
	
	data["body_text"] = body_text.text

func _on_back_button_pressed():
	save_page()
	queue_free()

func add_page_check():
	if id >= Globals.journal_data.size():
		Globals.add_page()
