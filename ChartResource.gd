extends Resource
class_name ChartResource

@export var base_bpm : float = 120.0
@export var time_signature : Vector2i = Vector2i(4,4)
@export var chart_data : PackedVector3Array
@export var audio : AudioStreamWAV
@export var difficulty : float = 0.0
@export var title : String = "Unknown"
@export var artist : String = "Also Unknown"
@export var charter : String = "Still Unknown"

func _init(b_bpm = 120.0, t_sig = Vector2i(4,4), chartdata = PackedVector3Array(), audio_stream = AudioStreamWAV.new(), diff = 0.0, n_title = "Unknown", n_artis = "Also Unknown", n_charter = "Still Unknown"):
	base_bpm = b_bpm
	time_signature = t_sig
	chart_data = chartdata
	audio = audio_stream
	difficulty = diff
	title = n_title
	artist = n_artis
	charter = n_charter
	
