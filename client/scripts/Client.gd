extends Node

const Level = preload("res://shared/scenes/ArenaTest2.tscn")
const Player = preload("res://scenes/Player.tscn")
const Chat = preload("res://scenes/ChatContainer.tscn")

var total_missing_packets : int = 0

func _ready():
	ClientData.level = Level.instance()
	ClientData.level.name = "Level"
	add_child(ClientData.level)
	
	ClientData.player = Player.instance()
	ClientData.player.set_name("Player")
	ClientData.player.transform.origin = Vector3(0, 10, 0)
	add_child(ClientData.player)
	
	ClientData.chat = Chat.instance()
	ClientData.chat.set_name("Chat")
	add_child(ClientData.chat)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("change_mouse_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
func _process(delta):
	if ClientData.connected:
		$InputHandler.process_input(delta)

func _physics_process(delta) -> void:
	if ClientData.connected:
		$PlayersHandler.process_other_players(delta)

func handle_tick_update(update : Dictionary):
	if update.has("missing_packets"):
		total_missing_packets += update["missing_packets"]
		var total_loss_rate = total_missing_packets / float(ClientData.input_counter)
		$Player/CanvasLayer/Control/PacketLoss.set_text(
			"Lost packets: " + str(update["missing_packets"]) + ", " + str(total_missing_packets) + "/" + str(ClientData.input_counter) + " (" + str(total_loss_rate) + ")"
		)


































