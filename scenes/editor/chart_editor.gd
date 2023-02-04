extends Control

@export var view_start_time : float = 0.0
@export var view_end_time : float = 1.0
@export var chart : ChartResource = ChartResource.new()
@export var audio : AudioStreamWAV
@export var audio_stream_player : AudioStreamPlayer
@export var playback_bar : HSlider
@export var rhythm_chart_input : Node
@export var spectrum_viewer : Node
@export var playback_button : Button
@export var save_popup : FileDialog
@export var open_popup : FileDialog
# Called when the node enters the scene tree for the first time.
func _ready():
	
	playback_bar.max_value = audio_stream_player.stream.get_length()
	pass # Replace with function body.

func update_the_stuff():
	var song_time = audio_stream_player.get_playback_position()
	playback_bar.value = song_time
	var time_length = view_end_time-view_start_time
	
	rhythm_chart_input.display_start_time = song_time-time_length/2.0
	rhythm_chart_input.display_end_time = song_time+time_length/2.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if audio_stream_player.playing:
		update_the_stuff()
		rhythm_chart_input.accept_inputs = false
	else:
		rhythm_chart_input.accept_inputs = true
	pass


func recieve_display_start_time(n_time):
	view_start_time = n_time
	spectrum_viewer.view_time_start = n_time
	spectrum_viewer.update_view_times()

func recieve_display_end_time(n_time):
	view_end_time = n_time
	spectrum_viewer.view_time_end = n_time
	spectrum_viewer.update_view_times()

func recieve_note_added(note_time):
	chart.chart_data.append(Vector3(0.0,0.0,note_time))

func toggle_playback():
	if audio_stream_player.playing:
		audio_stream_player.stop()
	else:
		audio_stream_player.play((view_start_time+view_end_time)/2.0)
	playback_button.text = "PAUSE" if audio_stream_player.playing else "PLAY"

func fill_chart_data():
	chart.chart_data.clear()
	for time in rhythm_chart_input.note_times:
		chart.chart_data.append(Vector3(0.0,0.0,time))

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			toggle_playback()
	if event.is_action_pressed("save"):
		save_popup.popup()
	if event.is_action_pressed("open"):
		open_popup.popup()

func _on_spin_box_value_changed(value):
	audio_stream_player.pitch_scale = value
	pass # Replace with function body.


func _on_open_chart_file_selected(path):
	chart = ResourceLoader.load(path)
	rhythm_chart_input.note_times.clear()
	for note in chart.chart_data:
		var idx = rhythm_chart_input.note_times.bsearch(note.z)
		rhythm_chart_input.note_times.insert(idx, note.z)
	pass # Replace with function body.


func _on_save_chart_file_selected(path):
	fill_chart_data()
	var err = ResourceSaver.save(chart,path)
	if err == OK:
		print("yay")
	else:
		print("oof ", err)
	pass # Replace with function body.


func _on_h_slider_drag_ended(value_changed):
	print("clicked the thing ", playback_bar.value)
	audio_stream_player.seek(playback_bar.value)
	update_the_stuff()
	pass # Replace with function body.


func _on_button_pressed():
	toggle_playback()
	
	pass # Replace with function body.
