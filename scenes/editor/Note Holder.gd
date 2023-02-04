extends Node2D

var drawn_notes : PackedFloat32Array = PackedFloat32Array([])
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
#	draw_set_transform_matrix(global_transform.affine_inverse())
	
	for note_time in drawn_notes:
#		draw_circle(Vector2(note_time,0.0),10,Color.BLUE)
		draw_line(Vector2(note_time,0.0),Vector2(note_time,1080.0), Color.BLUE, 10.0/global_scale.x)
