class_name PageButton extends Button

@onready var public_title_label: Label = $PublicTitle
@onready var date_label: Label = $Date

@onready var page: Resource = preload("res://scenes/page.tscn")

var id: int
var creation_date: int

func setup(id: int, creation_date: int, public_title: String):
	self.id = id
	self.creation_date = creation_date
	
	public_title_label.text = public_title + " ID: " + str(id)
	var date_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(creation_date)
	date_label.text = str(date_time_dict["month"]) + "/" + str(date_time_dict["day"]) + "/" + str(date_time_dict["year"])

func _on_pressed():
	var page_inst: Page = page.instantiate()
	get_parent().get_parent().get_parent().get_parent().add_child(page_inst)
	page_inst.setup(id, creation_date)
