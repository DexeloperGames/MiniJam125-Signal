extends Control

@export var bpm = 128.0
@export var offset = 0.0
@export var subdivs = 1:
	set(n_subdivs):
		subdivs = n_subdivs
		if not is_inside_tree(): await ready
		grid_material.set_shader_parameter("Divisions", subdivs)
@onready var grid_material = $ColorRect.material
@export var display_start_time = 0.0:
	set(n_display_start_time):
		display_start_time = n_display_start_time
		if not is_inside_tree(): await ready
		grid_material.set_shader_parameter("Display_Start_Time", display_start_time)
		get_tree().call_group("Display Time Recievers", "recieve_display_start_time", display_start_time)

@export var display_end_time = 1.0:
	set(n_display_end_time):
		display_end_time = n_display_end_time
		if not is_inside_tree(): await ready
		grid_material.set_shader_parameter("Display_End_Time", display_end_time)
		get_tree().call_group("Display Time Recievers", "recieve_display_end_time", display_end_time)

@export var zoom_level = 0:
	set(n_lvl):
		zoom_level = n_lvl
		zoom_factor = 10.0**zoom_level
@export var display_length = 1.0:
	get:
		display_length = display_end_time-display_start_time
		return display_length
@export var accept_inputs : bool = true
var note_times : PackedFloat32Array = PackedFloat32Array([])
var zoom_factor = 1.0
# Called when the node enters the scene tree for the first time.
#func _init():
#	await ready
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var visible_beats = bpm/60*display_length
	if visible_beats < 4:
		self.subdivs = 2**ceil(log(4/display_length*60/bpm)/log(2))
		pass
	pass
	var t = convert_position_to_time(get_global_mouse_position())
	t = get_snapped_time(t)
	var p = convert_time_to_position(t)
	$MultiMeshInstance2D.global_position = p
	$MultiMeshInstance2D.position.y = size.y/2.0
	$"Note Holder".global_transform = get_global_transform_with_canvas()
	$"Note Holder".global_position = convert_time_to_position(0.0)
	$"Note Holder".scale.x = size.x/display_length

func convert_position_to_time(global_pos):
	var matrix = $ColorRect.get_global_transform_with_canvas()
	var local_pos = global_pos*matrix.affine_inverse()
	var time_pos = remap(local_pos.x,0,$ColorRect.size.x, display_start_time, display_end_time)
	return time_pos
	pass

func convert_time_to_position(time):
	var matrix = $ColorRect.get_global_transform_with_canvas()
	var local_pos = remap(time,display_start_time, display_end_time, 0, $ColorRect.size.x)
	return Vector2(local_pos,0)*matrix

func get_snapped_time(real_time):
	return snapped(real_time,60/(bpm*subdivs))

func add_note(time):
	print("ADDING THE NOTE AT ", time)
#	get_tree().call_group("Note Recievers", "recieve_note_added", time)
	var idx = note_times.bsearch(time)
	note_times.insert(idx, time)
	draw_notes()

func remove_note(time):
	print("REMOVING NEAREST NOTE TO ", time)
	if note_times.is_empty(): return
	var idx = note_times.bsearch(time)
	note_times.remove_at(idx)
	draw_notes()

func draw_notes():
	$"Note Holder".drawn_notes = note_times
	$"Note Holder".queue_redraw()

func _on_color_rect_gui_input(event):
	if !accept_inputs: return
	var event_time_pos = convert_position_to_time(event.global_position)
	if event is InputEventMouseButton:
#		print(event)
#		event.global_position
		if event.is_action("zoom_in") or event.is_action("zoom_out"):
#			print("okay mouse ig")
			var zoom_scroll_amount = Input.get_axis("zoom_in","zoom_out")
			var zoom_amount = zoom_scroll_amount*0.01
			self.zoom_level += zoom_scroll_amount*0.01
			
	#		var mix_factor = remap(event_time_pos,display_start_time,display_end_time,0,1)
			self.display_start_time = event_time_pos + (display_start_time-event_time_pos)*10**zoom_amount
			self.display_end_time = event_time_pos + (display_end_time-event_time_pos)*10**zoom_amount
#		self.display_start_time *= 10.0**(zoom_amount*mix_factor)
#		self.display_end_time *= 10.0**(zoom_amount*(1.0-mix_factor))
		elif event.is_action("scroll_backwards") or event.is_action("scroll_forwards"):
			var pan_scroll_amount = Input.get_axis("scroll_backwards","scroll_forwards")
			
	#		var display_length = display_end_time-display_start_time
			var scroll_amount = display_length*0.0025*pan_scroll_amount
			self.display_start_time += scroll_amount
			self.display_end_time += scroll_amount
#		grid_material.set_shader_parameter("Time_Test", event_time_pos)
	if event.is_action_pressed("add_note"):
		var mouse_pos = get_global_mouse_position()
		var mouse_time = convert_position_to_time(mouse_pos)
		var note_time = get_snapped_time(mouse_time)
		add_note(note_time)
		pass
	if event.is_action_pressed("remove_note"):
		var mouse_pos = get_global_mouse_position()
		var mouse_time = convert_position_to_time(mouse_pos)
		var note_time = get_snapped_time(mouse_time)
		remove_note(note_time)
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouse:
		grid_material.set_shader_parameter("Time_Test", convert_position_to_time(event.global_position))
