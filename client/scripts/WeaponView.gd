extends Spatial


var base_stats : Dictionary = { "bullet_velocity": 50, "fire_rate": 45, "recoil": 137, "handling": 122, "movement": 18, "reload": 55 }
var element_effects = {
	"fire": {
		"effects": {
			"bullet_velocity": 20.0,
			"fire_rate": -20.0,
		},
		"traits": [
			"Hits on enemies cause burn damage"
		]
	},
	"ice": {
		"effects": {
			"reload": 20.0,
			"handling": -20.0
		},
		"traits": [
			"Hits on enemies cause delayed health regeneration"
		]
	}, 
	"earth": {
		"effects": {
			"recoil": 20.0,
			"movement": -20.0
		},
		"traits": [
			"Enemies that are hit are knocked back further that normal"
		]
	}, 
	"fusion": {
		"effects": {
			"fire_rate": 20.0,
			"bullet_velocity": -20.0
		},
		"traits": [
			"This gun's fires projectiles with no bullet drop"
		]
	}, 
	"poison": {
		"effects": {
			"handling": 20.0,
			"reload": -20.0
		},
		"traits": [
			"Hits on enemies cause them to become poisoned - their health will temporarily be 80% of normal"
		]
	}, 
	"wind": {
		"effects": {
			"movement": 20.0,
			"recoil": -20.0
		},
		"traits": [
			"???"
		]
	}
}

var attribute_meshes : Dictionary
var element_inputs : Dictionary
var element_labels : Dictionary
var stats : Dictionary
var elements: Dictionary = { "fire": 0, "ice": 0, "earth": 0, "fusion": 0, "poison": 0, "wind": 0 }
var bar_animation_speed : float = 0.25
var bar_height : int = 40
var margin : int = 20
var text_input_width : int = 100
var text_input_height : int = 40
var label_width : int = 200
var label_height : int = 40

func _ready():
	stats = base_stats.duplicate()
	get_tree().get_root().connect("size_changed", self, "on_size_changed")
	$CanvasLayer/Control/ExitButton.connect("pressed", self, "exit_button_pressed")
	
	$CanvasLayer/Control/Preview.texture = $Viewport.get_texture()
	
	attribute_meshes["bullet_velocity"] = $CanvasLayer/bullet_velocity_mesh
	attribute_meshes["fire_rate"] = $CanvasLayer/fire_rate_mesh
	attribute_meshes["recoil"] = $CanvasLayer/recoil_mesh
	attribute_meshes["handling"] = $CanvasLayer/handling_mesh
	attribute_meshes["movement"] = $CanvasLayer/movement_mesh
	attribute_meshes["reload"] = $CanvasLayer/reload_mesh
	
	element_inputs["fire"] = $CanvasLayer/Control/fire_text_input
	element_inputs["ice"] = $CanvasLayer/Control/ice_text_input
	element_inputs["earth"] = $CanvasLayer/Control/earth_text_input
	element_inputs["fusion"] = $CanvasLayer/Control/fusion_text_input
	element_inputs["poison"] = $CanvasLayer/Control/poison_text_input
	element_inputs["wind"] = $CanvasLayer/Control/wind_text_input
	
	element_labels["fire"] = $CanvasLayer/Control/fire_label
	element_labels["ice"] = $CanvasLayer/Control/ice_label
	element_labels["earth"] = $CanvasLayer/Control/earth_label
	element_labels["fusion"] = $CanvasLayer/Control/fusion_label
	element_labels["poison"] = $CanvasLayer/Control/poison_label
	element_labels["wind"] = $CanvasLayer/Control/wind_label
	
	on_size_changed()
	
func _process(delta):
	$CanvasLayer/Control/Background.rect_size.x = OS.get_window_size().x
	$CanvasLayer/Control/Background.rect_size.y = OS.get_window_size().y
	
	for attr in attribute_meshes.keys():
		attribute_meshes[attr].transform.origin.x = lerp(attribute_meshes[attr].transform.origin.x, stats[attr] + margin, bar_animation_speed)
		attribute_meshes[attr].scale.x = lerp(attribute_meshes[attr].scale.x, stats[attr], bar_animation_speed)
		
	update()
	
	$Viewport/Gun.rotation.y += 0.01
	
func on_size_changed():
	$CanvasLayer/Control/Preview.rect_size.x = OS.get_window_size().x
	$CanvasLayer/Control/Preview.rect_size.y = OS.get_window_size().y
	$Viewport.size.x = OS.get_window_size().x
	$Viewport.size.y = OS.get_window_size().y
	
	var elements_count = 1
	for key in element_inputs.keys():
		element_inputs[key].connect("text_changed", self, "text_edit_text_changed", [key])
		element_inputs[key].text = str(elements[key])
		
		element_inputs[key].margin_left = OS.get_window_size().x - margin - text_input_width
		element_inputs[key].margin_right = OS.get_window_size().x - margin
		element_inputs[key].margin_top = OS.get_window_size().y - ((element_inputs.keys().size() + 1) * (bar_height + margin)) + ((bar_height + margin) * elements_count)
		element_inputs[key].margin_bottom = OS.get_window_size().y - ((element_inputs.keys().size() + 1) * (bar_height + margin)) + ((bar_height + margin) * elements_count) + text_input_height
		
		element_labels[key].text = key + ": " + str(elements[key]) + " (0%)"
		element_labels[key].set("custom_colors/font_color", Color(0,0,0))
		element_labels[key].margin_left = OS.get_window_size().x - margin - text_input_width - margin - label_width
		element_labels[key].margin_right = OS.get_window_size().x - margin - text_input_width - margin
		element_labels[key].margin_top = OS.get_window_size().y - ((element_labels.keys().size() + 1) * (bar_height + margin)) + ((bar_height + margin) * elements_count)
		element_labels[key].margin_bottom = OS.get_window_size().y - ((element_labels.keys().size() + 1) * (bar_height + margin)) + ((bar_height + margin) * elements_count)  + label_height

		elements_count += 1
	
	var attribute_count = 1
	for key in attribute_meshes.keys():
		attribute_meshes[key].transform.origin.y = OS.get_window_size().y - ((attribute_meshes.keys().size() + 1) * (bar_height + margin)) + ((bar_height + margin) * attribute_count)
		attribute_meshes[key].transform.origin.x = stats[key] + margin
		attribute_meshes[key].scale.x = stats[key]
		attribute_count += 1

func exit_button_pressed():
	get_tree().quit()

func text_edit_text_changed(key : String):
	elements[key] = int(element_inputs[key].text)

func update():	
	stats = base_stats.duplicate()
	
	var total_elements : int = 0
	for key in element_inputs.keys():
		total_elements += int(element_inputs[key].text)
		
	for key in element_labels.keys():
		if total_elements > 0:
			var percentage : float = (float(element_inputs[key].text) / float(total_elements))
			element_labels[key].text = key + ": " + element_inputs[key].text + " (" + str(percentage * 100)  + "%)"
			
			if int(element_inputs[key].text) > 0:
				for attr in element_effects[key]["effects"].keys():
					stats[attr] = base_stats[attr] + float(element_effects[key]["effects"][attr] * percentage)
		else:
			element_labels[key].text = key + ": " + element_inputs[key].text + " (0%)"
			
		
	
# NOTES

# bullet_velocity
# fire_rate
# recoil
# handling
# movement
# reload

#fire
#ice
#earth
#fusion
#poison
#wind
