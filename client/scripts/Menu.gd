extends Panel

signal join_signal(ip_address, player_name)

func _ready():
	$Button.connect("pressed", self, "button_pressed")
#	$TextEdit.text = "157.230.0.57"
	$TextEdit.text = "127.0.0.1"

func button_pressed():
	emit_signal("join_signal", $TextEdit.text, $TextEdit2.text)
