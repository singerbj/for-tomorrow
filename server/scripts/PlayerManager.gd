extends Node
var Player = preload("res://scenes/Player.tscn")


func set_up_new_player(player_id : int):
	print("User " + str(player_id) + " connected")
	ServerData.players[player_id] = Player.instance()
	get_node("..").add_child(ServerData.players[player_id])
	ServerData.players[player_id].transform.origin = Vector3(0, 10, 0)
	ServerData.packet_loss[player_id] = {"last_packet" : 0, "total_lost" : 0}
	ServerData.input_buffer[player_id] = []
	
	return {
		"transform" : Utility.array_from_transform(ServerData.players[player_id].transform),
		"velocity" : Utility.array_from_vec3(ServerData.players[player_id].velocity)
	}
	
	
func remove_player(player_id : int):
	print("User " + str(player_id) + " disconnected")
	ServerData.players[player_id].queue_free()
	ServerData.packet_loss.erase(player_id)
	ServerData.players.erase(player_id)
	ServerData.input_buffer.erase(player_id)
