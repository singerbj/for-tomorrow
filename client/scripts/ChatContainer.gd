extends Control

const MAX_lines = 10
const COLOR_TEAM = '#AAAAFF'
const COLOR_GLOBAL = '#FFFFAA'

var is_open : bool = false
var mode : String
var chatlog: Array

onready var Log = get_node("VBoxContainer/RichTextLabel")
onready var inputLine = get_node("VBoxContainer/InputLine")
onready var inputField = get_node("VBoxContainer/InputLine/LineEdit")
onready var inputLabel = get_node("VBoxContainer/InputLine/Label")
onready var sanitizer = get_node("VBoxContainer/Sanitizer")


func _ready() -> void:
	inputLine.visible = false

	
func _input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.release_focus()
		if not inputField.has_focus():
			if Input.is_action_just_pressed("global_chat"):
				inputField.grab_focus()
				inputLabel.text = "[Chat]"
				inputLabel.set("custom_colors/font_color", Color(COLOR_GLOBAL))
				mode = "normal"
			if Input.is_action_just_pressed("team_chat"):
				inputField.grab_focus()
				inputLabel.text = "[Team]"
				inputLabel.set("custom_colors/font_color", Color(COLOR_TEAM))
				mode = "team"


func _on_LineEdit_text_changed(new_text : String) -> void:
	if !is_open:
		is_open = true
		inputField.clear()


func _on_LineEdit_focus_entered() -> void:
	inputLine.visible = true


func _on_LineEdit_focus_exited() -> void:
	inputField.clear()
#	print("clear")
	is_open = false
	inputLine.visible = false

func _on_LineEdit_text_entered(new_text) -> void:
	var text = new_text.strip_edges(true, true)
	inputField.release_focus()
	if text.length() > 0:
		# add_message(text, "You") # remove this
		Server._send_message(text, mode)


func receive_from_server(msg : String, usr : String, chat_mode : String, color_msg = '#ffffff', color_usr = '#ffffff') -> void:
	if chat_mode == "global":
		add_message(msg, usr, COLOR_GLOBAL, COLOR_GLOBAL)
	elif chat_mode == "team":
		add_message(msg, usr, COLOR_TEAM, COLOR_TEAM)
	elif chat_mode == "ping":
		get_tree().root.get_node("Map/Ping_UI").add_ping(msg, usr)
	else:
		add_message(msg, usr, color_msg, color_usr)

func add_message(msg, usr, color_msg = '#ffffff', color_usr = '#ffffff') -> void:
	sanitizer.bbcode_text = msg # parse BBCode and then use the text part to avoid user abuse
	chatlog.append("[" + usr + "]: " + sanitizer.text)
	Log.bbcode_text += "\n"
	Log.bbcode_text += "[color=" + color_usr + "][" + usr + "]:[/color] "
	Log.bbcode_text += "[color=" + color_msg + "]" + sanitizer.text + "[/color]"
	# play sound
	while Log.get_line_count() > MAX_lines:
		Log.remove_line(0)

func beep():
#	print("beep")
	return
