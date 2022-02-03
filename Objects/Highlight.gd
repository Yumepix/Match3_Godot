extends Control


var vertical_pos := Vector2(0,0)
var vertical_size := Vector2(0,0)

var horizontal_pos := Vector2(0,0)
var horizontal_size := Vector2(0,0)

var couleur = Color(1,1,1,0.5)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

func _process(delta):
	pass
	
func _draw():
	draw_rect(Rect2(vertical_pos,vertical_size),couleur,true,1.0,false)
	draw_rect(Rect2(horizontal_pos,horizontal_size),couleur,true,1.0,false)


func destroy():
	queue_free()
