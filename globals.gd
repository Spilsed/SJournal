extends Node

var journal_data: Array = []

var json: JSON = JSON.new()

var aes: AESContext = AESContext.new()
var key: String:
	set(value):
		key = value.sha256_text().left(32)
		iv = value.sha256_text().right(16)
var iv: String

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var save_path: String = "user://"

# Settings
var public_titles_enabled: bool = true

func attempt_init_decrypt():
	if !load_journal_data():
		return false
	
	return true

func save_journal_data():
	var file = FileAccess.open(save_path+"journal_data.dat", FileAccess.WRITE)
	file.store_var(aes_encrypt(array_to_bytes(journal_data)))

func load_journal_data():
	var file = FileAccess.open(save_path+"journal_data.dat", FileAccess.READ)
	if file != null:
		journal_data = bytes_to_array(aes_decrypt(file.get_var()))
		
		# Parse failed
		if journal_data == ["err"]:
			return false
		
		return true
	elif file == null:
		save_journal_data()
		return true
	return false

# TODO: Make work using some copy file function
func backup_journal_data():
	var load_file = FileAccess.open(save_path+"journal_data.dat", FileAccess.READ)
	var backup_file = FileAccess.open(save_path+"journal_data_backup_"+str(Time.get_unix_time_from_system())+".dat", FileAccess.WRITE)

func add_page(public_title: String = "Unnamed") -> void:
	var file_name: String = str(rng.randf_range(-100000, 100000)).sha256_text()
	rng.randomize()
	journal_data.append({"file_name": file_name, "creation_date": Time.get_unix_time_from_system(), "public_title": public_title if public_titles_enabled else "Unnamed"})
	save_journal_data()

func aes_encrypt(data) -> PackedByteArray:
	match typeof(data):
		TYPE_DICTIONARY:
			data = dict_to_bytes(data)
		TYPE_ARRAY:
			data = array_to_bytes(data)
		TYPE_PACKED_BYTE_ARRAY:
			pass
		_:
			return PackedByteArray([])
	
	aes.start(AESContext.MODE_CBC_ENCRYPT, key.to_utf8_buffer(), iv.to_utf8_buffer())
	var encrypted: PackedByteArray = aes.update(data)
	aes.finish()
	return encrypted

func aes_decrypt(data: PackedByteArray) -> PackedByteArray:
	aes.start(AESContext.MODE_CBC_DECRYPT, key.to_utf8_buffer(), iv.to_utf8_buffer())
	var decrypted: PackedByteArray = aes.update(data)
	aes.finish()
	return decrypted

func array_to_bytes(dict: Array) -> PackedByteArray:
	var save_data: String = json.stringify(dict)
	if save_data.to_utf8_buffer().size() % 16 != 0:
		save_data += "@"
		for i in 16 - (save_data.length() % 16):
			save_data += ";"
	return save_data.to_utf8_buffer()

func bytes_to_array(bytes: PackedByteArray) -> Array:
	var string: String = bytes.get_string_from_utf8()
	# Check for padding
	if string.find("@;") != -1:
		# Remove padding
		json.parse(string.left(string.find("@;")))
	else:
		# Special remove padding if it is only one byte of padding
		if string[-1] == "@":
			string = string.left(string.length() - 1)
		json.parse(string)
	
	# Parse failed?
	if json.data == null:
		return ["err"]
	
	return json.data

func dict_to_bytes(dict: Dictionary) -> PackedByteArray:
	var save_data: String = json.stringify(dict)
	if save_data.to_utf8_buffer().size() % 16 != 0:
		save_data += "@"
		for i in 16 - (save_data.length() % 16):
			save_data += ";"
	return save_data.to_utf8_buffer()

func bytes_to_dict(bytes: PackedByteArray) -> Dictionary:
	var string: String = bytes.get_string_from_utf8()
	# Check for padding
	if string.find("@;"):
		# Remove padding
		json.parse(string.left(string.find("@;")))
		return json.data
	else:
		# Special remove padding if it is only one byte of padding
		if string[-1] == "@":
			string = string.left(string.length() - 1)
		json.parse(string)
		return json.data

func data_exists():
	return FileAccess.open(save_path+"journal_data.dat", FileAccess.READ) != null

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_journal_data()
		get_tree().quit()
