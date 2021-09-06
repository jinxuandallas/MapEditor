extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var vstr="   xxx yyy   "
#	print(vstr.lstrip(" ").rstrip(" ")+"aaa")
	print(vstr.strip_edges()+"bbb")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
