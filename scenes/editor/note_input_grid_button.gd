extends TextureButton
class_name NoteGridButton

@export var note_index : int = 0
@export var direction_index : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("toggled",_on_toggled)
	pass # Replace with function body.

signal grid_button_toggled(button, pressed_state)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_toggled(buttonpressed):
	emit_signal("grid_button_toggled", self, buttonpressed)
