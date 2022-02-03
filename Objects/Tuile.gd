extends Area2D

var initial_z_index = 0
var taken_z_index = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = initial_z_index


func init(nb, pos):
	$SpriteTuile.play("planete")
	$SpriteTuile.stop()
	$SpriteTuile.frame = nb
	position = pos

func set_transparent():
	$SpriteTuile.play("planete")
	$SpriteTuile.stop()

func _process(delta):
	var pos_in_grid = get_parent().get_grid_position(position)
	var inst
	if get_parent().global_grid[pos_in_grid.x][pos_in_grid.y] != null:
		inst = get_parent().global_grid[pos_in_grid.x][pos_in_grid.y].get_instance_id()
	else:
		inst = "null"
	$Infos.set("custom_colors/font_color", Color(1,1,0,1))
	$Infos.text = str(inst)
	

func move_tuile(new_pos):
	$Tween.interpolate_property(self, "position", position, new_pos, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")



func _on_Tuile_mouse_entered():
	$SpriteTuile.scale = Vector2(1.1,1.1)


func _on_Tuile_mouse_exited():
	$SpriteTuile.scale = Vector2(1,1)
