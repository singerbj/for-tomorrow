extends Node

var level
var player
var chat
var player_buffer : Array = [] 		# Buffer containing the most recent information about other players

var input_queue : Array = []		# FIFO input buffer
var input_counter : int = 0			# unique ID for all inputs. Goes up to 2^63, overflow unlikely.
var prediction_errors = 0

var total_mouse_motion : Vector2 = Vector2(0, 0)	# aggregate mouse movement between frames

# How long to keep extrapolating player movements after not receiving data anymore
#var max_extrapolation_time_ms : float = 500 # 500ms

const EPSILON = 1

var connected = false

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

var PLAYER_CAMERA_DEFAULT_FOV = 90
var PLAYER_CAMERA_ADS_FOV = 70

