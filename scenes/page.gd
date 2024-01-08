class_name Page extends Control

var id: int
var creation_date: int

var data: Dictionary = {"title_text": "", "body_text": ""}

func _init(id: int = Globals.journal_data.size(), creation_date: int = Time.get_unix_time_from_system()):
	self.id = id
	self.creation_date = creation_date
	load_page()

func save_page() -> void:
	Globals.journal_data[id] = data
	var file: FileAccess = FileAccess.open(Globals.journal_data[id]["file_name"], FileAccess.WRITE)
	file.store_var(Globals.aes_encrypt(Globals.json.stringify(data).to_utf8_buffer()))

func load_page() -> bool:
	if id < 0 or id >= Globals.journal_data.size():
		return false
	
	var file: FileAccess = FileAccess.open(Globals.journal_data[id]["file_name"], FileAccess.READ)
	Globals.json.parse(Globals.aes_decrypt(file.get_var()).get_string_from_utf8())
	data = Globals.json.data
	Globals.json.data = ""
	return true
