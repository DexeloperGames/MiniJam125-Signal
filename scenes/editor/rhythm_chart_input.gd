extends Control

@export var bpm = 120.0
@export var offset = 0.0
@export var subdivs = 4
@onready var grid_material = $ColorRect.material
@export var display_start_time = 0.0:
	set(n_display_start_time):
		display_start_time = n_display_start_time
		grid_material.set_shader_parameter("Display_Start_Time", display_start_time)

@export var display_end_time = 1.0:
	set(n_display_end_time):
		display_end_time = n_display_end_time
		_onready_set_display_end_time.call(display_end_time)
		
var _onready_set_display_end_time = func _onready_set_display_end_time_(n_end_time):
	await ready
	await RenderingServer.frame_pre_draw
	if is_inside_tree() or true:
		var new_onready_set_display_end_time = func new_setget(n_e_t):
			grid_material.set_shader_parameter("Display_End_Time", display_end_time)
		replace_function_onready_display_end_time(new_onready_set_display_end_time)
		self.display_end_time = n_end_time
	
	
func replace_function_onready_display_end_time(theworseone):
	_onready_set_display_end_time = theworseone
	await RenderingServer.frame_pre_draw
	_onready_set_display_end_time.call(display_end_time)
@export var zoom_level = 0:
	set(n_lvl):
		zoom_level = n_lvl
		zoom_factor = 10.0**zoom_level
var zoom_factor = 1.0
# Called when the node enters the scene tree for the first time.
#func _init():
#	await ready
func _ready():
	await RenderingServer.frame_pre_draw
	_onready_set_display_end_time.call(display_end_time)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_onready_set_display_end_time.call(display_end_time)
	pass


func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		var scroll_amount = Input.get_axis("scroll_backwards","scroll_forwards")
		var zoom_amount = scroll_amount*0.01
		self.zoom_level += scroll_amount*0.01
		display_start_time *= 10.0**zoom_amount
		display_end_time *= 10.0**zoom_amount
	pass # Replace with function body.
