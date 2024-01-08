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

func _ready():
	key = "Ayushi"
	save_journal_data()
	load_journal_data()
	print("H:", journal_data)

func save_journal_data():
	var file = FileAccess.open("user://journal_data.dat", FileAccess.WRITE)
	file.store_var(aes_encrypt(array_to_bytes(journal_data)))

func load_journal_data():
	var file = FileAccess.open("user://journal_data.dat", FileAccess.READ)
	journal_data = bytes_to_array(aes_decrypt(file.get_var()))

# TODO: Make work using some copy file function
func backup_journal_data():
	var load_file = FileAccess.open("user://journal_data.dat", FileAccess.READ)
	var backup_file = FileAccess.open("user://journal_data_backup_"+str(Time.get_unix_time_from_system())+".dat", FileAccess.WRITE)

func add_page(public_title: String = "Unnamed") -> void:
	var file_name: String = str(rng.randf_range(-100000, 100000)).sha256_text()
	journal_data.append({"file_name": file_name, "creation_date": Time.get_unix_time_from_system(), "public_title": public_title})
	save_journal_data()

func aes_encrypt(data: PackedByteArray) -> PackedByteArray:
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
	if string.find("@;"):
		json.parse(string.left(string.find("@;")))
		print(json.data)
		return json.data
	else:
		json.parse(string)
		return json.data
