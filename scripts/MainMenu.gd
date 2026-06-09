extends Control

@onready var start_button: Button = $StartButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var class_selector: HBoxContainer = $ClassSelector
@onready var warrior_button: Button = $ClassSelector/WarriorButton
@onready var mage_button: Button = $ClassSelector/MageButton
@onready var archer_button: Button = $ClassSelector/ArcherButton
@onready var assassin_button: Button = $ClassSelector/AssassinButton

var selected_class: int = 0

func _ready():
    start_button.pressed.connect(_on_start_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)
    quit_button.pressed.connect(_on_quit_button_pressed)
    
    warrior_button.pressed.connect(func(): select_class(0))
    mage_button.pressed.connect(func(): select_class(1))
    archer_button.pressed.connect(func(): select_class(2))
    assassin_button.pressed.connect(func(): select_class(3))

func select_class(class_index: int):
    selected_class = class_index
    
    warrior_button.modulate = Color(1, 1, 1) if class_index == 0 else Color(0.5, 0.5, 0.5)
    mage_button.modulate = Color(1, 1, 1) if class_index == 1 else Color(0.5, 0.5, 0.5)
    archer_button.modulate = Color(1, 1, 1) if class_index == 2 else Color(0.5, 0.5, 0.5)
    assassin_button.modulate = Color(1, 1, 1) if class_index == 3 else Color(0.5, 0.5, 0.5)

func _on_start_button_pressed():
    var game_scene = get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
    game_scene.call_deferred("set_player_class", selected_class)

func _on_settings_button_pressed():
    get_tree().change_scene_to_file("res://scenes/SettingsScene.tscn")

func _on_quit_button_pressed():
    get_tree().quit()