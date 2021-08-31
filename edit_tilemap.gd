extends Node2D
class_name MapEditor

const SPEED=400

var in_edge
var active_color_rect
#存储地图上的信息
var map_data=[]
var mouse_position
var map_state:=[]

onready var background=$ParallaxBackground
onready var margin_container=$"Viewport/MarginContainer"
onready var screen_size=get_viewport_rect().size
onready var map=$"ParallaxBackground/ParallaxLayer/Map"
onready var _DetectMouseRect=$Viewport/MarginContainer/Control
onready var map_num=get_tree().get_meta("MapNum")


func _ready():
#	get_tree().set_meta("MapNum","1")
#	map_num="1"
	
	#检查有没有设置MapNum变量
	if !get_tree().has_meta("MapNum"):
		print("没有设定地图编号")
		get_tree().change_scene("res://select_tilemap.tscn")
		return
		
	map.texture=load("res://Map/%s.jpg"%map_num)
	
	for i in 21:
		var l=Line2D.new()
		l.add_point(Vector2(i*50,0))
		l.add_point(Vector2(i*50,1000))
		l.default_color=Color.red
		l.width=2
		map.add_child(l)
		
	for i in 21:
		var l=Line2D.new()
		l.add_point(Vector2(0,i*50))
		l.add_point(Vector2(1000,i*50))
		l.default_color=Color.red
		l.width=2
		map.add_child(l)
	
	_load_map()
#	print(map_data)
	
	for i in 20:
#		var line_data=[]
		for j in 20:
			var cr=ColorRect.new()
			cr.rect_position=Vector2(j*50,i*50)
			cr.rect_size=Vector2(50,50)
			cr.name="Cell%d,%d"%[i,j]
			#初始化所有格子的颜色
			var type=map_data[i][j]
			cr.color=_get_color(type)
			if type==0:
				cr.color.a=0
			else:
				cr.color.a=0.6
				
#			cr.visible=false
			cr.connect("mouse_entered",self,"_on_ColorRect_mouse_entered",[cr])
			cr.connect("mouse_exited",self,"_on_ColorRect_mouse_exited",[cr])
			map.add_child(cr)
			
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect1.color=Color.goldenrod
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect2.color=Color.yellowgreen
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect3.color=Color.dodgerblue
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect4.color=Color.cornflower
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect5.color=Color.darkgreen
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect6.color=Color.darkorange
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect7.color=Color.sienna
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect8.color=Color.cadetblue
	$ParallaxBackground/ParallaxLayer/GridContainer/ColorRect9.color=Color.firebrick
	
	$ConfirmDialog.get_cancel().connect("pressed",self,"_on_ConfirmDialog_canelled")


func _input(event):
	$Viewport.input(event)
	
	if event is InputEventMouse:
		mouse_position = event.position
		in_edge = ! _DetectMouseRect.get_rect().has_point(mouse_position)
	
	if event is InputEventKey:
		if event.scancode==KEY_ESCAPE:
				$ConfirmDialog.popup()
				
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
		_save_map()
		
#	if Input.is_key_pressed(KEY_ESCAPE):
#		$ConfirmDialog.popup()
		
	if (Input.is_key_pressed(KEY_KP_0) or Input.is_key_pressed(KEY_0)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(0)
		return
	if (Input.is_key_pressed(KEY_KP_1) or Input.is_key_pressed(KEY_1)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(1)
		return
	if (Input.is_key_pressed(KEY_KP_2) or Input.is_key_pressed(KEY_2)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(2)
		return
	if (Input.is_key_pressed(KEY_KP_3) or Input.is_key_pressed(KEY_3)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(3)
		return
	if (Input.is_key_pressed(KEY_KP_4) or Input.is_key_pressed(KEY_4)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(4)
		return
	if (Input.is_key_pressed(KEY_KP_5) or Input.is_key_pressed(KEY_5)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(5)
		return
	if (Input.is_key_pressed(KEY_KP_6) or Input.is_key_pressed(KEY_6)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(6)
		return
	if (Input.is_key_pressed(KEY_KP_7) or Input.is_key_pressed(KEY_7)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(7)
		return
	if (Input.is_key_pressed(KEY_KP_8) or Input.is_key_pressed(KEY_8)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(8)
		return
	if (Input.is_key_pressed(KEY_KP_9) or Input.is_key_pressed(KEY_9)) and Input.is_key_pressed(KEY_CONTROL):
		_fill(9)
		return
	
		
	if active_color_rect!=null:
		if Input.is_key_pressed(KEY_KP_0) or Input.is_key_pressed(KEY_0):
			_handle_pressed(0)
		if Input.is_key_pressed(KEY_KP_1) or Input.is_key_pressed(KEY_1):
			_handle_pressed(1)
		if Input.is_key_pressed(KEY_KP_2) or Input.is_key_pressed(KEY_2):
			_handle_pressed(2)
		if Input.is_key_pressed(KEY_KP_3) or Input.is_key_pressed(KEY_3):
			_handle_pressed(3)
		if Input.is_key_pressed(KEY_KP_4) or Input.is_key_pressed(KEY_4):
			_handle_pressed(4)
		if Input.is_key_pressed(KEY_KP_5) or Input.is_key_pressed(KEY_5):
			_handle_pressed(5)
		if Input.is_key_pressed(KEY_KP_6) or Input.is_key_pressed(KEY_6):
			_handle_pressed(6)
		if Input.is_key_pressed(KEY_KP_7) or Input.is_key_pressed(KEY_7):
			_handle_pressed(7)
		if Input.is_key_pressed(KEY_KP_8) or Input.is_key_pressed(KEY_8):
			_handle_pressed(8)
		if Input.is_key_pressed(KEY_KP_9) or Input.is_key_pressed(KEY_9):
			_handle_pressed(9)
		
	
			
func _physics_process(delta):
	if in_edge:
		var mouse_pos=get_viewport().get_mouse_position()
#	if mouse_pos.x>screen_size.x-margin_container.get_constant("margin_right")||mouse_pos.x<margin_container.get_constant("margin_left")||mouse_pos.y<margin_container.get_constant("margin_top")||mouse_pos.y>screen_size.y- margin_container.get_constant("margin_bottom"):
#		print(mouse_pos)
		if mouse_pos.x>screen_size.x-margin_container.get_constant("margin_right"):
			background.scroll_offset.x+=delta*SPEED
			
		if mouse_pos.x<margin_container.get_constant("margin_left"):
			background.scroll_offset.x-=delta*SPEED

		if mouse_pos.y<margin_container.get_constant("margin_top"):
			background.scroll_offset.y+=delta*SPEED
			
		if mouse_pos.y>screen_size.y- margin_container.get_constant("margin_bottom"):
			background.scroll_offset.y-=delta*SPEED
		
		background.scroll_offset.x=clamp(background.scroll_offset.x,0,280)
		background.scroll_offset.y=clamp(background.scroll_offset.y,-400,0)
		
	
func _fill(key_type):
	var refresh=false #判断是否有格子改变了类型
	if active_color_rect==null:
		return
#	print(active_color_rect.name)
#	print(active_color_rect.name.lstrip("Cell"))
#	print(active_color_rect.name.lstrip("Cell").split(",",false))
	
	var coordinate=active_color_rect.name.lstrip("Cell").split(",",false)
#	print(map_data[coordinate[0] as int][coordinate[1] as int])
	var ref_value=map_data[coordinate[0] as int][coordinate[1] as int]
	for i in 20:
		for j in 20:
			if map_data[i][j]==ref_value:
				if !refresh:
					refresh=true
				map_data[i][j]=key_type
	
	if refresh:
		for i in 20:
			for j in 20:
				var type=map_data[i][j]
				var cellname="Cell%d,%d"%[i,j]
				var cr=get_node("ParallaxBackground/ParallaxLayer/Map/%s"%cellname)
				cr.color=_get_color(type)
				if type==0:
					cr.color.a=0
				else:
					cr.color.a=0.6
	
func _handle_pressed(key_type):		#处理按键后的逻辑
	var coordinate=_get_color_rect_num(active_color_rect)
	map_data[coordinate.y][coordinate.x]=key_type
	active_color_rect.color=_get_color(key_type)
	active_color_rect.color.a=0.6

func _get_color_rect_num(color_rect:ColorRect):		#根据ColorRect对象判断其在map_data中的坐标
	var x=color_rect.rect_position.x/50
	var y=color_rect.rect_position.y/50
	return Vector2(x,y)

func _save_map():
	var save_file=File.new()
	save_file.open("res://Json/%s.json"%map_num,File.WRITE)
#	var json={"name":"xxx","value":"yyy","age":18}
	var l=1
	var map_dic:Dictionary
	while l<=map_data.size():
		map_dic[l]=map_data[l-1]
		l+=1
		
	save_file.store_string(JSON.print(map_dic,"\t"))
#	print(JSON.print(map_dic,"\t"))
	save_file.close()
	
	#存储地图状态
	var state=1	#1代表地图全部设置过了
	for i in map_data:
		if i.find(0)!=-1:
			state=0
			break
			
	#保存地图最后一步，将新设置的地图是否全部编辑完毕状态保存到总地图的json文件中
	_load_mapstate()
	
	map_state[map_num as int]=state
	
	_save_mapstate()
	
func _save_mapstate():
	var save_file=File.new()
	var state={"MapState":map_state}
	save_file.open("res://Json/map_state.json",File.WRITE)
	save_file.store_string(JSON.print(state,"\t"))
	save_file.close()

func _load_map():
	var file=File.new()
	var filename="res://Json/%s.json"%map_num
	if not file.file_exists(filename):
		print("文件不存在")
		_format_mapdata()
		return
		
	file.open(filename,File.READ)
#	var line=[]
#	while file.get_position()<file.get_len():
	var map_json=parse_json(file.get_as_text())
#	print(map_json)
	if map_json.size()>0:
		map_data.clear()
		
		for i in map_json:
			var line_int=[]
			for j in map_json[i]:
				line_int.append(j as int)
			map_data.append(line_int)
			
	else:
		_format_mapdata()
		
	file.close()
#	
func _format_mapdata():
	for i in 20:
		var line_data=[]
		for j in 20:
			line_data.append(0)
		map_data.append(line_data)

func _on_ColorRect_mouse_entered(color_rect):
	color_rect.color=Color(1,1,1,0.6)
	active_color_rect=color_rect

func _on_ColorRect_mouse_exited(color_rect):
	var coordinate=_get_color_rect_num(color_rect)
	var type=map_data[coordinate.y][coordinate.x]  #用json转换成Array所有的数字都转成了float，所以这里需要强制转换成int
	color_rect.color=_get_color(type)
	if type==0:
		color_rect.color.a=0
	else:
		color_rect.color.a=0.6
		
	active_color_rect=null

func _get_color(type):		#根据不同类型返回相应颜色
	var return_color
	match type:
		0:
			return_color=Color(1,1,1)
		1:
			return_color=Color.goldenrod
		2:
			return_color=Color.yellowgreen
		3:
			return_color=Color.dodgerblue
		4:
			return_color=Color.cornflower
		5:
			return_color=Color.darkgreen
		6:
			return_color=Color.darkorange
		7:
			return_color=Color.sienna
		8:
			return_color=Color.cadetblue
		9:
			return_color=Color.firebrick
	return return_color


func _on_ConfirmDialog_confirmed():
	_save_map()
	get_tree().change_scene("res://select_tilemap.tscn")

func _on_ConfirmDialog_canelled():
	get_tree().change_scene("res://select_tilemap.tscn")

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
		map_state=map_json["MapState"]
		
#		for i in map_json["MapState"]:
#			map_state.append(i as int)
	else:
		_format_mapstate()
		
	file.close()

#生成108个位0的数组，并存入map_state.json文件中
func _format_mapstate():
	map_state.clear()
	for i in 108:
		map_state.append(0)
		
	_save_mapstate()
#	var save_file=File.new()
#	var state={"MapState":map_state}
#	save_file.open("res://Json/map_state.json",File.WRITE)
#	save_file.store_string(JSON.print(state,"\t"))
#	save_file.close()
