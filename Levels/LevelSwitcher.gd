extends Node


func _on_level_complete(level_name, next_level_name):
	if level_name == "Credits":
		get_tree().quit()
	elif next_level_name != null:
		get_tree().change_scene_to(load("res://Levels/" + next_level_name + ".tscn"))
	else:
		get_tree().change_scene_to(load("res://Levels/Credits.tscn"))

func _screen_cap():
	# start screen capture
	#get_viewport().queue_screen_capture()
	#yield(get_tree(), "idle_frame")
	#
	
	# get screen capture
	#var capture = get_viewport().get_screen_capture()
	# save to a file
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var capture = get_viewport().get_texture().get_data()
	capture.flip_y()
	capture.save_png("res://screenshot" + var2str(OS.get_unix_time()) + ".png")

func _ready():
	set_process_input(true)
func _input(event):
	if event.is_action_pressed("screenshot"):
		_screen_cap()