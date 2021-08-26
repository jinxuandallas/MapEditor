class_name MyTextureRect
extends TextureRect

signal my_mouse_entered(my_texture_rect)
signal my_mouse_exited(my_texture_rect)
#集成方式，暂且不用
#var num
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	self.connect("_my_mouse_entered",self,"_on_MyTextureRect_mouse_entered")
	connect("mouse_entered",self,"_on_TextureRect_mouse_entered")
	connect("my_mouse_exited",self,"_on_TextureRect_mouse_exited")


func _on_TextureRect_mouse_entered():
	emit_signal("my_mouse_entered",self)
	
func _on_TextureRect_mouse_exited():
	emit_signal("my_mouse_exited",self)
#func _on_MyTextureRect_mouse_entered(my_texture_rect):
#	print(my_texture_rect.name)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
