extends Node

var journal_data: Dictionary = {"test_data": 10020}

var aes: AESContext = AESContext.new()
var json: JSON = JSON.new()

var key: String:
	set(value):
		key = value.sha256_text().left(32)

var save_file: FileAccess

func _ready():
	save_file = FileAccess.open("user://journal_data.dat", FileAccess.WRITE_READ)
	key = "Hellar"
	save_journal_data()
	load_journal_data()

func save_journal_data():
	aes.start(AESContext.MODE_ECB_ENCRYPT, key.to_utf8_buffer())
	var save_data: String = json.stringify(journal_data)
	
	# Padding
	if save_data.to_utf8_buffer().size() % 16 != 0:
		save_data += "@"
		for i in 16 - (save_data.length() % 16):
			save_data += "<"
	
	save_file.store_string(aes.update(save_data.to_utf8_buffer()).get_string_from_utf8())
	aes.finish()

func load_journal_data():
	aes.start(AESContext.MODE_ECB_DECRYPT, key.to_utf8_buffer())
	print(save_file.get_as_text())
	var decrypted_text: String = aes.update(save_file.get_as_text().to_utf8_buffer()).get_string_from_utf8()
	print(decrypted_text)
	journal_data = json.data
	aes.finish()
