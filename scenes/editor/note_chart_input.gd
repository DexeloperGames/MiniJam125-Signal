extends Control

@export var chart : ChartResource
@export var chart_dimension : ChartDimension
@export var chart_dimension_viewport : SubViewport
@export var chart_dimensions_viewport_container : SubViewportContainer
@export var audio_stream_player : AudioStreamPlayer
@export var button_grid_container : GridContainer
var index_offset = 0
var button_grid_array : Array[Array]
var directions_array : Array[Vector2] = [Vector2(-1.0,0.0),Vector2(0.0,1.0),Vector2(0.0,-1.0),Vector2(1.0,0.0)]
# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.connect("frame_pre_draw", _on_frame_draw_pre)
	initialize_input_grid()
	chart = ResourceLoader.load("res://full time chart hopefully yay.tres")
	chart_dimension.chart = chart
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize_input_grid():
	var button_grid_nodes = button_grid_container.get_children().filter(func(node): return node is NoteGridButton)
	print("printing o wait i never called it oops")
	print(button_grid_nodes)
	var columns = button_grid_container.columns
	var rows = ceili(len(button_grid_nodes)/columns)
	button_grid_array.resize(rows)
#	button_grid_array.fill()
	print(button_grid_array)
	for i in range(len(button_grid_nodes)):
		var col = i%columns
		var row = floori(i/columns)
		button_grid_nodes[i].note_index = row
		button_grid_nodes[i].direction_index = col
		button_grid_nodes[i].connect("grid_button_toggled", _on_grid_button_toggled)
		button_grid_array[row].append(button_grid_nodes[i])
	print(button_grid_array)
	pass

func update_chart_directions(index, direction):
	var dir = directions_array[direction]
	chart.chart_data[index].x = dir.x
	chart.chart_data[index].y = dir.y
	chart_dimension.load_chart()
	pass

func _on_frame_draw_pre():
#	chart_dimension_viewport.size
#	chart_dimension_viewport.size = chart_dimensions_viewport_container.get_global_rect().size
	pass


func _on_grid_button_toggled(button, pressed_state):
	print(button)
	print(pressed_state)
	print(button.note_index)
	print(button.direction_index)
	if button.button_pressed:
		update_chart_directions(button.note_index+index_offset, button.direction_index)
		for buttons in button_grid_array[button.note_index].filter(func(check): return check != button):
			buttons.button_pressed = false
#		button.button_pressed = true
