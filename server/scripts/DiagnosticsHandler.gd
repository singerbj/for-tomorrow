extends Node


func handle_diagnostics(buffer):
	return
	for pid in buffer.keys():
		var tick_info = {}
		tick_info["missing_packets"] = 0
		
		# deep copy to not modify original buffer object
		var queue = buffer[pid].duplicate(true)
		while not queue.empty():
			var packet = queue.pop_front()
			var missing_packets = packet["packet_id"] - ServerData.packet_loss[packet["player_id"]]["last_packet"] - 1
			ServerData.packet_loss[packet["player_id"]]["total_lost"] += missing_packets
			ServerData.packet_loss[packet["player_id"]]["last_packet"] = packet["packet_id"]
				
			tick_info["missing_packets"] += missing_packets
		
		get_node("..").send_diagnostics(pid, tick_info)
