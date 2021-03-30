extends Panel

signal join_signal(ip_address, player_name)

func _ready():
	$Button.connect("pressed", self, "button_pressed")

func button_pressed():
	emit_signal("join_signal", $TextEdit.text, $TextEdit2.text)
