extends Control

@export var view_time_start : float = 0.0
@export var view_time_end : float = 1.0
@export var view_frequency_start : float = 261.625
@export var view_frequency_end : float = 261.625*4
#@export var audio_sample_rate : int = 44100
@export var audio : AudioStreamWAV
@export var audio_texture : ImageTexture

enum SPECTRUM_MODE{
	LINEAR = 0,
	LOGARITHMIC = 1
}
@export_enum("Linear", "Logarithmic") var spectrum_display_mode = 0

func generate_wave_image():
	var audio_data = audio.data
	if audio.format == AudioStreamWAV.FORMAT_16_BITS and audio.stereo:
		var sample_count = len(audio_data)/4
		var image_size : int = int(ceil(sqrt(sample_count)))
		var pixel_count = image_size*image_size
		var pixels : PackedVector2Array = PackedVector2Array()
		pixels.resize(pixel_count)
		pixels.fill(Vector2.ZERO)
		
		var audio_data_buffer : StreamPeerBuffer = StreamPeerBuffer.new()
#		print(audio_data_buffer)
		audio_data_buffer.set_data_array(audio_data)
		
		for i in range(sample_count):
			var x = audio_data_buffer.get_16()/32767.0
			var y = audio_data_buffer.get_16()/32767.0
			pixels[i] = Vector2(x,y)
#			var 
		var wave_image = Image.create_from_data(image_size,image_size, false,Image.FORMAT_RGF, pixels.to_byte_array())
		var wave_texture = ImageTexture.create_from_image(wave_image)
		audio_texture = wave_texture
		return wave_texture
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.connect("frame_pre_draw", _on_pre_frame_draw)
	generate_wave_image()
	$SubViewport/ColorRect.material.set_shader_parameter("audio_texture", audio_texture)
#	var view_texture = $SubViewport.get_texture()
#	material.set_shader_parameter("Spectrum_Viewport", view_texture)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_view_times():
	$SubViewport/ColorRect.material.set_shader_parameter("start_time", view_time_start)
	$SubViewport/ColorRect.material.set_shader_parameter("end_time", view_time_end)
func _on_pre_frame_draw():
#	pass
	$SubViewport.size.x = ceil(get_global_rect().size.x)
	$SubViewport/ColorRect.size.x = ceil(get_global_rect().size.x)
