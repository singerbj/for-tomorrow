extends Node

var port = 29995
var max_players = 100
var count = 0

var players : Dictionary = {}
var world : Dictionary = {}

# Dictionary (indexed with player ids) of Arrays (sequences of inputs)
# of Dictionaries (Input states - buttons, motions, input id
var input_buffer : Dictionary = {}
var packet_loss : Dictionary = {}	# player_id : {"last_packet" : int, "total_lost" : int}

var SENS_MULTIPLIER : float = 0.05
