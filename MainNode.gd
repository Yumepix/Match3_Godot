extends Node2D

const CELL_SIZE = 64

var is_in_grid = false
var width_container = 0
var height_container = 0
var grid_nb_cols = 0
var grid_nb_rows = 0

var global_grid = []
var stase_grid = []

var pos_taken_tuile := Vector2(0,0)
var origin_pixel := Vector2(0,0)
var taken_tuile = null
var highlight = null
var matching_release = false
var empty_cell = null
var tuile_de_susbtitution = null
var is_taken = false

onready var CR = $ColorRect

# le préload va permettre d'économiser en mémoire
var Tuile = preload("res://Objects/Tuile.tscn")
var HL = preload("res://Objects/Highlight.tscn")

func _ready():
	# taille du container
	width_container = CR.get_rect().size.x
	height_container = CR.get_rect().size.y
	
	# nombre de colonnes et de lignes
	grid_nb_cols = floor(width_container / CELL_SIZE)
	grid_nb_rows = floor(height_container / CELL_SIZE)

	# création de la grille
	global_grid = initialize_tab()
	

func _physics_process(delta):
	
	var pos_mouse = get_global_mouse_position()
	is_in_grid = is_cursor_in_grid(pos_mouse)
	
	if is_in_grid:
		if (Input.is_action_just_pressed("ui_left")):
			# position de la case où l'on a récupéré la tuile
			pos_taken_tuile = get_grid_position(pos_mouse)
	
			# la tuile récupérée
			# taken_tuile est donc un node Area2d
			taken_tuile = global_grid[pos_taken_tuile.x][pos_taken_tuile.y]
		
			# on crée une tuile que l'on va insérer dans l'emplacement vide
			tuile_de_susbtitution = Tuile.instance()
			#empty_tuile.set_transparent()
			global_grid[pos_taken_tuile.x][pos_taken_tuile.y] = tuile_de_susbtitution
			
			### highlight
			highlight = HL.instance()
			add_child(highlight)
			origin_pixel = get_pixel_position(pos_taken_tuile.x,pos_taken_tuile.y)
		
			highlight.horizontal_pos = Vector2(CR.rect_position.x, origin_pixel.y-(CELL_SIZE/2))
			highlight.horizontal_size = Vector2(CR.rect_size.x,CELL_SIZE)
			
			highlight.vertical_pos = Vector2(origin_pixel.x-(CELL_SIZE/2), CR.rect_position.y)
			highlight.vertical_size = Vector2(CELL_SIZE,CR.rect_size.y)
			
			
			empty_cell = pos_taken_tuile
			# la copie du tableau va nous servir au rollback
			stase_grid = global_grid.duplicate(true)
			is_taken = true
			

		if (Input.is_action_pressed("ui_left")):
			taken_tuile.z_index = taken_tuile.taken_z_index
			taken_tuile.position = pos_mouse

			### move
			check_cells(pos_taken_tuile,get_grid_position(pos_mouse))
			
			
	if is_taken:
		if (Input.is_action_just_released("ui_left") || !is_in_grid):
			taken_tuile.z_index = taken_tuile.initial_z_index
			
		#	matching_release = true
			
			if (!matching_release):
				taken_tuile.move_tuile(origin_pixel)
				# on remet la tuile dans le tableau
				global_grid[pos_taken_tuile.x][pos_taken_tuile.y] = taken_tuile
			elif(matching_release):
				taken_tuile.move_tuile(get_pixel_position(empty_cell.x,empty_cell.y))
				global_grid[empty_cell.x][empty_cell.y] = taken_tuile
				
			stase_grid = []
			highlight.queue_free()
			is_taken = false



func is_cursor_in_grid(pos_mouse):
	if pos_mouse.x > CR.get_rect().position.x \
	and pos_mouse.x < CR.get_rect().position.x+CR.get_rect().size.x \
	and pos_mouse.y > CR.get_rect().position.y \
	and pos_mouse.y < CR.get_rect().position.y+ CR.get_rect().size.y:
		return true
	else:
		return false



func check_cells(origin:Vector2, current:Vector2):
	
	# origin : coordonnées de la case prise
	# current : coordonnées de la case actuelle
	var nb_cells_to_move_y = origin.y-current.y
	var nb_cells_to_move_x = origin.x-current.x
	
	if origin.x == current.x and origin.y == current.y:
		rollback_grid()
		# quand la case du milieu est null on ne peut pas faire de switch
		empty_cell = current
		return

	# attention changer la condition sur le matching release, ce n'est que pour le test
	if origin.x != current.x and origin.y != current.y:
		matching_release = false
		rollback_grid()
	else:
		matching_release = true
	

	# sur la ligne verticale
	if origin.x == current.x:
		if nb_cells_to_move_y > 0:
			for y in range(empty_cell.y,current.y,-1):
				#print("vers le bas") 
				global_grid[origin.x][y-1].move_tuile(get_pixel_position(origin.x,y))
				global_grid[origin.x][y] = global_grid[origin.x][y-1]
			global_grid[current.x][current.y] = tuile_de_susbtitution
			empty_cell = current
		
		elif nb_cells_to_move_y < 0:
			#print("vers le haut")
			for y in range(empty_cell.y,current.y):
				global_grid[origin.x][y+1].move_tuile(get_pixel_position(origin.x,y))
				global_grid[origin.x][y] = global_grid[origin.x][y+1]
			global_grid[current.x][current.y] = tuile_de_susbtitution
			empty_cell = current


	# sur la ligne horizontale	
	if origin.y == current.y:
		if nb_cells_to_move_x > 0:
			#print("vers la droite") 
			for x in range(empty_cell.x,current.x,-1):
				global_grid[x-1][origin.y].move_tuile(get_pixel_position(x,origin.y))
				global_grid[x][origin.y] = global_grid[x-1][origin.y]
			global_grid[current.x][current.y] = tuile_de_susbtitution
			empty_cell = current
		elif nb_cells_to_move_x < 0:
			#print("vers la gauche")
			for x in range(empty_cell.x,current.x):
				global_grid[x+1][origin.y].move_tuile(get_pixel_position(x,origin.y))
				global_grid[x][origin.y] = global_grid[x+1][origin.y]
			global_grid[current.x][current.y] = tuile_de_susbtitution
			empty_cell = current

	if origin.x != current.x and origin.y != current.y:
		empty_cell = origin

			
func rollback_grid():
	for x in grid_nb_cols:
		for y in grid_nb_rows:
			if stase_grid[x][y] != global_grid[x][y]:
				global_grid[x][y] = stase_grid[x][y]
				if global_grid[x][y] != tuile_de_susbtitution:
					global_grid[x][y].move_tuile(get_pixel_position(x,y))





# donne la position en pixel (vecteur) en fonction de la ligne et colonne
func get_pixel_position(col, row):
# warning-ignore:integer_division
	var x = CR.rect_position.x + (col * CELL_SIZE) + (CELL_SIZE / 2)
# warning-ignore:integer_division
	var y = CR.rect_position.y + (row * CELL_SIZE) + (CELL_SIZE / 2)
	return Vector2(x, y)


# donne la position de la ligne et colonne en fonction des pixels
func get_grid_position(pos:Vector2):
	var x = floor((pos.x - CR.rect_position.x) / CELL_SIZE)
	var y = floor((pos.y - CR.rect_position.y) / CELL_SIZE)
	return Vector2(x, y)
	

func initialize_tab():
	randomize()
	var matrix=[]
	for i in grid_nb_cols:
		matrix.append([])
		for j in grid_nb_rows:
			var t = Tuile.instance()
			var pos = get_pixel_position(i,j)
			var image_index = floor(rand_range(0,5))
			t.init(image_index,pos)
			matrix[i].append(t)
			add_child(t)
	
	return matrix
