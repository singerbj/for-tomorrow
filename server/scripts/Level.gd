extends Spatial

func _ready():
	print(name)


func update_world(world):
	for pos in world.keys():
		$GridMap.set_cell_item(pos.x, pos.y, pos.z, world[pos])
