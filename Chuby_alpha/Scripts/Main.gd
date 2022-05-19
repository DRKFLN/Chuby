extends Node

signal on_pause_state_change

var current_scene_ref: WeakRef
var level := 0
#var title_screen: Control

var show_pause_sceen = false
var is_game_started = false

var levels = [
	 "res://levels/level_1/Level1.tscn",
	"res://levels/level_2/Level2.tscn"
]

func _ready():#получение текущей сцены при загрузке для последующего уаления
	pause_mode = Node.PAUSE_MODE_PROCESS
	var root = get_tree().get_root()
	var scene = root.get_child(root.get_child_count() - 1)
	current_scene_ref = weakref(scene)

func _process(delta):
	if is_game_started and Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
		

func go_to_next_level():
	level += 1
	goto_scene(levels[level])

func goto_scene(scene_path):
	var scene = load(scene_path)
	call_deferred("_deferred_goto_scene", scene)

func toggle_pause():
	show_pause_sceen = !show_pause_sceen
	get_tree().paused = show_pause_sceen
	emit_signal("on_pause_state_change", show_pause_sceen)

func start_new_game():
	is_game_started = true
	level = 0
	goto_scene(levels[level])


func exit_game():
	get_tree().quit()

func _deferred_goto_scene(scene: PackedScene): #получение сылки на новую сцену
	#уничтожение прошлой сцены
	var current_scene = current_scene_ref.get_ref()
	if current_scene:
		current_scene.free()

	# открытие новой сцены
	var new_scene = scene.instance()
	current_scene_ref = weakref(new_scene)#получение ссылки на сцену

	# доавление сцены как дочерней
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)
