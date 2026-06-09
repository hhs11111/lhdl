extends Control

var selected_class: int = 0
var class_names: Array = ["战士", "法师", "弓箭手", "刺客"]
var class_colors: Array = [Color(0.7, 0.6, 0.5), Color(0.6, 0.4, 0.8), Color(0.5, 0.6, 0.3), Color(0.3, 0.3, 0.4)]

@onready var start_button: Button = $StartButton
@onready var class_prev: Button = $ClassPrev
@onready var class_next: Button = $ClassNext
@onready var class_label: Label = $ClassLabel
@onready var class_preview: ColorRect = $ClassPreview

func _ready():
    start_button.pressed.connect(_on_start)
    class_prev.pressed.connect(_on_prev_class)
    class_next.pressed.connect(_on_next_class)
    _update_class_display()

func _on_start():
    get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
    var game = get_tree().current_scene
    if game and game.has_method("set_player_class"):
        game.set_player_class(selected_class)

func _on_prev_class():
    selected_class = (selected_class - 1 + 4) % 4
    _update_class_display()

func _on_next_class():
    selected_class = (selected_class + 1) % 4
    _update_class_display()

func _update_class_display():
    class_label.text = "职业: " + class_names[selected_class]
    class_preview.color = class_colors[selected_class]
