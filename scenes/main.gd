extends Control

@onready var title_label : Label = $VBoxContainer/Title
@onready var top_layer: CanvasLayer = $Top
@onready var browse_container: VBoxContainer = $BrowseBackground/VBoxContainer/ScrollContainer/VBoxContainer
@onready var browse_background: ColorRect = $BrowseBackground
@onready var settings_background: ColorRect = $SettingsBackground

@onready var page: Resource = preload("res://scenes/page.tscn")
@onready var page_button: Resource = preload("res://scenes/support/page_button.tscn")

func update_browse_menu():
	# Delete all existing children
	for child in browse_container.get_children():
		child.queue_free()
	
	# Add all new children
	var reverse_order: Array = range(len(Globals.journal_data))
	reverse_order.reverse()
	for i in reverse_order:
		var page_button_inst: PageButton = page_button.instantiate()
		browse_container.add_child(page_button_inst)
		page_button_inst.setup(i, Globals.journal_data[i]["creation_date"], Globals.journal_data[i]["public_title"])

func _on_new_page_pressed():
	var page_inst: Page = page.instantiate()
	top_layer.add_child(page_inst)
	page_inst.setup()

func _on_search_pages_pressed():
	browse_background.show()
	update_browse_menu()

func _on_settings_pressed():
	settings_background.show()

func _on_export_pressed():
	for i in range(len(Globals.journal_data)):
		DirAccess.open(Globals.save_path).make_dir("exports")
		var file: FileAccess = FileAccess.open(Globals.save_path+"exports/export_"+str(i)+".txt", FileAccess.WRITE)
		var entry: FileAccess = FileAccess.open(Globals.save_path+Globals.journal_data[i]["file_name"], FileAccess.READ)
		var date_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(Globals.journal_data[i]["creation_date"])
		var date: String = str(date_time_dict["month"]) + "/" + str(date_time_dict["day"]) + "/" + str(date_time_dict["year"])
		
		file.store_string(Globals.journal_data[i]["public_title"]+ " : " + date + "\n\n" + Globals.bytes_to_dict(Globals.aes_decrypt(entry.get_var()))["body_text"])

func _on_quit_pressed():
	Globals.save_journal_data()
	get_tree().quit()

func _on_browse_back_pressed():
	browse_background.hide()

func _on_settings_back_pressed():
	settings_background.hide()

# Settings
func _on_public_titles_toggled(toggled_on):
	pass # Replace with function body.

func _on_recover_pressed():
	var file: FileAccess = FileAccess.open(Globals.save_path+"266fdb3a11bc6efc21a30f24f0b9a7b022200c34f5e02b08a85620901ca1a2c4", FileAccess.READ)
	print(Globals.bytes_to_dict(Globals.aes_decrypt(file.get_var())))
