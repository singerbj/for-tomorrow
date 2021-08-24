extends KinematicBody

var head_angle : float setget set_head_angle
var server_reconciliation_tween

func _ready() -> void:
	server_reconciliation_tween = Tween.new()
	add_child(server_reconciliation_tween)
	
func set_head_angle(angle):
	head_angle = angle
	$Head.rotation_degrees.x = angle

func server_reconcile(new_transform):
	server_reconciliation_tween.interpolate_property(
		self, "translation", 
		self.transform.origin, new_transform.origin, 0.025,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	server_reconciliation_tween.interpolate_property(
		self, "transform:basis", 
		self.transform.basis, new_transform.basis, 0.025,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	server_reconciliation_tween.start()
