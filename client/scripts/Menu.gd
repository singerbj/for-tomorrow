extends Panel

signal join_signal(ip_address, player_name)

func _ready():
	$Button.connect("pressed", self, "button_pressed")

#	var is_dev_env = OS.get_environment("GODOT_DEV_ENV")
#	if is_dev_env != "":
	print("Starting in dev environment!")
	$TextEdit.text = "127.0.0.1"
	emit_signal("join_signal", $TextEdit.text, $TextEdit2.text)
#	else:		
#		print("Starting in production environment!")
#		OS.window_fullscreen = true
#		$TextEdit.text = "157.230.0.57"

func _process(delta):
	self.rect_size.x = OS.get_screen_size().x
	self.rect_size.y = OS.get_screen_size().y

func button_pressed():
	emit_signal("join_signal", $TextEdit.text, $TextEdit2.text)
