extends Control

@onready var title_label : Label = $VBoxContainer/Title
@onready var page := preload("res://scenes/page.tscn")

func _on_new_page_pressed():
	Globals.add_page()
	var page_inst: Page = page.instantiate().set_script(Page.new())


func _on_search_pages_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()


func _on_hurry_pressed():
	title_label.text = "PRONKED BOZO!"
