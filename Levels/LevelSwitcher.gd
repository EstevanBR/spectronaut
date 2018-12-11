extends Node


func _on_level_complete(level_name, next_level_name):
	if level_name == "Credits":
		get_tree().quit()
	elif next_level_name != null:
		get_tree().change_scene_to(load("res://Levels/" + next_level_name + ".tscn"))
	else:
		get_tree().change_scene_to(load("res://Levels/Credits.tscn"))
