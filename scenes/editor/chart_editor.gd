extends Control

@export var view_start_time : float = 0.0
@export var view_end_time : float = 1.0
@export var chart : ChartResource = ChartResource.new():
	set(n_chart):
		chart = n_chart
		if not is_inside_tree(): await ready
		direction_chart_input.chart = n_chart
@export var audio : AudioStreamWAV
@export var audio_stream_player : AudioStreamPlayer:
	set(n_stream_player):
		audio_stream_player = n_stream_player
		if not is_inside_tree(): await ready
		direction_chart_input.audio_stream_player = n_stream_player
@export var playback_bar : HSlider
@export var rhythm_chart_input : Node
@export var direction_chart_input : Node
@export var spectrum_viewer : Node
@export var playback_button : Button
@export var save_popup : FileDialog
@export var open_popup : FileDialog
# Called when the node enters the scene tree for the first time.
func _ready():
	
	playback_bar.max_value = audio_stream_player.stream.get_length()
	self.audio_stream_player = audio_stream_player
	self.chart = chart
#	direction_chart_input.chart = chart
	
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
	for i in range(len(rhythm_chart_input.note_times)):#min(len(rhythm_chart_input.note_times),len(direction_chart_input.note_directions))):
#		var dir = direction_chart_input.note_directions[i]
		var dir = Vector2.ZERO #yeah i've completely given up on the built in editor ugh
		var time = rhythm_chart_input.note_times[i]
		chart.chart_data.append(Vector3(dir.x,dir.y,time))
	self.chart = chart
#	for time in rhythm_chart_input.note_times:
#		chart.chart_data.append(Vector3(0.0,0.0,time))


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
	self.chart = ResourceLoader.load(path)
	var cached_data : Array[Vector3] = Array(chart.chart_data.duplicate())
	cached_data.sort_custom(func(thing1, thing2): return thing1.z<thing2.z)
	for i in range(len(cached_data)):
		chart.chart_data[i] = cached_data[i]
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


func _on_tab_container_tab_button_pressed(tab):
	print("tabbed over")
	fill_chart_data()
	pass # Replace with function body.


func _on_tab_container_tab_changed(tab):
	print("tabbed ove r2")
	fill_chart_data()
	pass # Replace with function body.


func _on_bpm_box_value_changed(value):
	chart.base_bpm = value
	rhythm_chart_input.bpm = value
	get_tree().call_group("Song Data Recievers", "recieve_bpm", value)
	pass # Replace with function body.


func _on_charter_line_edit_text_submitted(new_text):
	print("yeah charter name ", new_text)
	pass # Replace with function body.


func _on_charter_line_edit_text_changed(new_text):
	print("yeah charter name ", new_text)
	chart.charter = new_text
	pass # Replace with function body.


func _on_artist_line_edit_text_changed(new_text):
	chart.artist = new_text
	pass # Replace with function body.


func _on_song_title_line_edit_text_changed(new_text):
	chart.title = new_text
	pass # Replace with function body.
