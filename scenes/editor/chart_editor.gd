extends Control

@export var view_start_time : float = 0.0
@export var view_end_time : float = 1.0
@export var chart : ChartResource = ChartResource.new()
@export var audio : AudioStreamWAV
# Called when the node enters the scene tree for the first time.
func _ready():
	
	$"Player Bar/HBoxContainer/HSlider".max_value = $AudioStreamPlayer.stream.get_length()
	pass # Replace with function body.

func update_the_stuff():
	var song_time = $AudioStreamPlayer.get_playback_position()
	$"Player Bar/HBoxContainer/HSlider".value = song_time
	var time_length = view_end_time-view_start_time
	
	$"Rhythm Chart Input".display_start_time = song_time-time_length/2.0
	$"Rhythm Chart Input".display_end_time = song_time+time_length/2.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $AudioStreamPlayer.playing:
		update_the_stuff()
		$"Rhythm Chart Input".accept_inputs = false
	else:
		$"Rhythm Chart Input".accept_inputs = true
	pass


func recieve_display_start_time(n_time):
	view_start_time = n_time
	$"Spectrum Viewer".view_time_start = n_time
	$"Spectrum Viewer".update_view_times()

func recieve_display_end_time(n_time):
	view_end_time = n_time
	$"Spectrum Viewer".view_time_end = n_time
	$"Spectrum Viewer".update_view_times()

func recieve_note_added(note_time):
	chart.chart_data.append(Vector3(0.0,0.0,note_time))

func toggle_playback():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.play((view_start_time+view_end_time)/2.0)
	$"Player Bar/HBoxContainer/Button".text = "PAUSE" if $AudioStreamPlayer.playing else "PLAY"

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			toggle_playback()
	if event.is_action_pressed("save"):
		$SaveChart.popup()
	if event.is_action_pressed("open"):
		$OpenChart.popup()

func _on_spin_box_value_changed(value):
	$AudioStreamPlayer.pitch_scale = value
	pass # Replace with function body.


func _on_open_chart_file_selected(path):
	chart = ResourceLoader.load(path)
	pass # Replace with function body.


func _on_save_chart_file_selected(path):
	var err = ResourceSaver.save(chart,path)
	if err == OK:
		print("yay")
	else:
		print("oof ", err)
	pass # Replace with function body.


func _on_h_slider_drag_ended(value_changed):
	print("clicked the thing ", $"Player Bar/HBoxContainer/HSlider".value)
	$AudioStreamPlayer.seek($"Player Bar/HBoxContainer/HSlider".value)
	update_the_stuff()
	pass # Replace with function body.


func _on_button_pressed():
	toggle_playback()
	
	pass # Replace with function body.
