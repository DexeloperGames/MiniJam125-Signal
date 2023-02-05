extends Node3D
class_name ChartDimension
@export var chart : ChartResource
@export var chart_path : Path3D
@export var chart_position : PathFollow3D
@export var multi_mesh_instance : MultiMeshInstance3D
@export var audio_stream_player : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	load_chart()
#	audio_stream_player.stream = chart.audio
#	chart.audio.instantiate_playback()
#	audio_stream_player.play()
	pass # Replace with function body.

#var t = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = audio_stream_player.get_playback_position()
	chart_position.progress = t*chart.base_bpm/60.0
#	t+= delta
	pass


var direction_array = [Vector3.RIGHT,Vector3.FORWARD,Vector3.LEFT,Vector3.BACK]
func load_chart():
	chart_path.curve.clear_points()
	multi_mesh_instance.multimesh.instance_count = len(chart.chart_data)
	var idx = 0
	var inst_idx = 0
	var prev_pos = Vector3.ZERO
	var prev_time = 0.0
	for note in chart.chart_data:
		var time_diff = note.z-prev_time
		var beat_length = time_diff*chart.base_bpm/60.0
		var dir = Vector3(note.x,0.0,note.y)
		if dir.length() <= 0.5:
			continue
		var new_pos = prev_pos+beat_length*dir
		chart_path.curve.add_point(new_pos)
		var mid_pos = (new_pos+prev_pos)/2.0
		var x_vector : Vector3 = new_pos-mid_pos
		var z_vector : Vector3 = x_vector.normalized().cross(Vector3(0,1,0))*0.01
		var instance_transform = Transform3D(x_vector, Vector3(0,1,0), z_vector, mid_pos)
		
		multi_mesh_instance.multimesh.set_instance_transform(inst_idx, instance_transform)
		
		prev_time = note.z
		prev_pos = new_pos
#		idx = (idx+1)%len(direction_array)
		inst_idx += 1
