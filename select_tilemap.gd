extends Node2D

const SPEED = 3000
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var in_edge
var zoom = 1 setget set_zoom
var MAX_ZOOM := 8.0
var MIN_ZOOM := 1
var ZOOM_PERIOD := 0.25

var MAP_SIZE_X = 12 * 1000
var MAP_SIZE_Y = 9 * 1000

var mouse_position := Vector2()
var current_border
var map_state=[]
var current_map_num

onready var _Camera2D = $Camera2D
onready var _Chunks = $Chunks
onready var _DetectMouseRect = $LayerMargin/ControlDetectMouse/MarginContainer/DetectMouseRect

onready var screen_size = get_viewport_rect().size
onready var screen_right_up_radian = Vector2(screen_size.x / 2, -screen_size.y / 2).angle()
onready var screen_left_up_radian = Vector2(-screen_size.x / 2, -screen_size.y / 2).angle()


func _ready():
	#设置边缘检测控件的尺寸，保持和屏幕大小一致
	$LayerMargin.size=screen_size
	$LayerMargin/ControlDetectMouse/MarginContainer.rect_size=screen_size
	
	for i in 9:
		for j in 12:
			var num = i * 12 + j
			
			var res_str = "res://Map/%d.jpg" % num

			var texture_rect = MyTextureRect.new()
			texture_rect.texture=load(res_str)
#			texture_rect.centered = false
			texture_rect.name="PartMap%d" %num
#			texture_rect.position = Vector2(j * 1000, i * 1000)
			texture_rect.margin_left=j*1000
			texture_rect.margin_top=i*1000
			texture_rect.connect("my_mouse_entered",self,"_on_MyTextureRect_mouse_entered")
			
			_Chunks.add_child(texture_rect)
			
	_load_mapstate()	#读取地图状态（是否全部设置过地图类型）

func _input(event):
	if event is InputEventMouse:
		mouse_position = event.position
		in_edge = ! _DetectMouseRect.get_rect().has_point(mouse_position)
		
		if event is InputEventMouseButton:	#判断鼠标滚轮按钮
			if event.button_index==BUTTON_WHEEL_UP:
				set_zoom(zoom - ZOOM_PERIOD)
				_Camera2D.zoom = Vector2(zoom, zoom)
				if(zoom<4):
					current_border.width=8 #随着地图缩放，调节线段宽度
				move_camera(Vector2())
			
			if event.button_index==BUTTON_WHEEL_DOWN:
				set_zoom(zoom + ZOOM_PERIOD)
				_Camera2D.zoom = Vector2(zoom, zoom)
				if(zoom>4):
					current_border.width=18 #随着地图缩放，调节线段宽度
				move_camera(Vector2())
				
			if event.button_index==BUTTON_LEFT:
					get_tree().set_meta("MapNum",current_map_num)
					get_tree().change_scene("res://edit_tilemap.tscn")


func _process(delta):
	if in_edge:
		#判断鼠标在哪个边界上
		var vector = mouse_position - screen_size / 2.0
		var radian = vector.angle()
		var scroll_idx := -1
		if radian <= 0:
			if screen_right_up_radian <= radian and radian <= 0:
				scroll_idx = 0
			if screen_left_up_radian <= radian and radian <= screen_right_up_radian:
				scroll_idx = 1
			if -PI <= radian and radian <= screen_left_up_radian:
				scroll_idx = 2
		else:
			if 0 <= radian and radian <= -screen_right_up_radian:
				scroll_idx = 0
			if -screen_right_up_radian <= radian and radian <= -screen_left_up_radian:
				scroll_idx = 3
			if -screen_left_up_radian <= radian and radian <= PI:
				scroll_idx = 2
		var camera_translation = Vector2()
		match scroll_idx:
			0:
				camera_translation.x = delta * SPEED * zoom
			1:
				camera_translation.y = -delta * SPEED * zoom
			2:
				camera_translation.x = -delta * SPEED * zoom
			3:
				camera_translation.y = delta * SPEED * zoom
		move_camera(camera_translation)

func move_camera(position_offset: Vector2):
	var size_x_half = get_viewport().size.x * zoom / 2.0
	var size_y_half = get_viewport().size.y * zoom / 2.0
	_Camera2D.position.x = clamp(
		_Camera2D.position.x + position_offset.x, size_x_half, MAP_SIZE_X - size_x_half
	)
	_Camera2D.position.y = clamp(
		_Camera2D.position.y + position_offset.y, size_y_half, MAP_SIZE_Y - size_y_half
	)


func set_zoom(new_zoom):
	zoom = clamp(new_zoom, MIN_ZOOM, MAX_ZOOM)


func _on_MyTextureRect_mouse_entered(my_texture_rect:MyTextureRect):
	if current_border != null:	#如果原来的边框存在，则先消除它，再画新的
		current_border.queue_free()
	current_border=Line2D.new()
	current_border.width=8 if zoom<4 else 18 #随着地图缩放，调节线段宽度
	current_border.default_color=Color.red
	current_border.add_point(Vector2(my_texture_rect.rect_position.x,my_texture_rect.rect_position.y))
	current_border.add_point(Vector2(my_texture_rect.rect_position.x+my_texture_rect.rect_size.x,my_texture_rect.rect_position.y))
	current_border.add_point(Vector2(my_texture_rect.rect_position.x+my_texture_rect.rect_size.x,my_texture_rect.rect_position.y+my_texture_rect.rect_size.y))
	current_border.add_point(Vector2(my_texture_rect.rect_position.x,my_texture_rect.rect_position.y+my_texture_rect.rect_size.y))
	current_border.add_point(Vector2(my_texture_rect.rect_position.x,my_texture_rect.rect_position.y))
	_Chunks.add_child(current_border)
	current_map_num=my_texture_rect.name.trim_prefix("PartMap")
	

func _load_mapstate():
	var file=File.new()
	if not file.file_exists("res://Json/map_state.json"):
		print("文件不存在")
		_format_mapstate()
		return
		
	file.open("res://Json/map_state.json",File.READ)
	var map_json=parse_json(file.get_as_text())

	if map_json.size()>0:
		map_state.clear()
		
		for i in map_json["MapState"]:
			map_state.append(i as int)
			if i as int ==1:
				get_node("Chunks/PartMap%d"%(map_state.size()-1)).modulate=Color.green
	else:
		_format_mapstate()

#生成108个位0的数组，并存入map_state.json文件中
func _format_mapstate():
	map_state.clear()
	for i in 108:
		map_state.append(0)
	var save_file=File.new()
	var state={"MapState":map_state}
	save_file.open("res://Json/map_state.json",File.WRITE)
	save_file.store_string(JSON.print(state,"\t"))
	save_file.close()
