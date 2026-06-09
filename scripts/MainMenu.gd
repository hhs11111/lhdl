extends Control

var selected_class: int = 0
var class_names: Array = ["战士", "法师", "弓箭手", "刺客"]
var class_colors: Array = [
    Color(0.85, 0.55, 0.3),
    Color(0.6, 0.45, 0.9),
    Color(0.5, 0.75, 0.4),
    Color(0.5, 0.3, 0.4)
]

var class_label: Label
var class_preview: ColorRect
var message_label: Label

func _ready():
    randomize()
    _build_ui()
    _update_class_display()

func _build_ui():
    var bg = ColorRect.new()
    bg.color = Color(0.05, 0.08, 0.15, 1.0)
    bg.anchor_right = 1.0
    bg.anchor_bottom = 1.0
    add_child(bg)

    var title = Label.new()
    title.text = "骑士传说"
    title.add_theme_font_size_override("font_size", 72)
    title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.anchor_left = 0.5
    title.anchor_right = 0.5
    title.offset_left = -400
    title.offset_right = 400
    title.offset_top = 60
    title.offset_bottom = 160
    add_child(title)

    var subtitle = Label.new()
    subtitle.text = "2D 刷宝冒险"
    subtitle.add_theme_font_size_override("font_size", 28)
    subtitle.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.anchor_left = 0.5
    subtitle.anchor_right = 0.5
    subtitle.offset_left = -300
    subtitle.offset_right = 300
    subtitle.offset_top = 170
    subtitle.offset_bottom = 210
    add_child(subtitle)

    var panel = PanelContainer.new()
    panel.anchor_left = 0.5
    panel.anchor_right = 0.5
    panel.offset_left = -200
    panel.offset_right = 200
    panel.offset_top = 260
    panel.offset_bottom = 540
    add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 20)
    panel.add_child(vbox)

    var margin1 = MarginContainer.new()
    margin1.add_theme_constant_override("margin_left", 20)
    margin1.add_theme_constant_override("margin_right", 20)
    margin1.add_theme_constant_override("margin_top", 20)
    margin1.add_theme_constant_override("margin_bottom", 10)
    vbox.add_child(margin1)

    class_label = Label.new()
    class_label.text = "职业: " + class_names[selected_class]
    class_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    class_label.add_theme_font_size_override("font_size", 32)
    class_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
    margin1.add_child(class_label)

    var margin2 = MarginContainer.new()
    margin2.add_theme_constant_override("margin_left", 40)
    margin2.add_theme_constant_override("margin_right", 40)
    margin2.add_theme_constant_override("margin_top", 10)
    margin2.add_theme_constant_override("margin_bottom", 10)
    vbox.add_child(margin2)

    class_preview = ColorRect.new()
    class_preview.color = class_colors[selected_class]
    class_preview.custom_minimum_size = Vector2(200, 140)
    margin2.add_child(class_preview)

    var preview_label = Label.new()
    preview_label.text = "↑ 预览颜色 ↑"
    preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    preview_label.add_theme_font_size_override("font_size", 16)
    preview_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
    vbox.add_child(preview_label)

    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 10)
    vbox.add_child(hbox)

    var margin3 = MarginContainer.new()
    margin3.add_theme_constant_override("margin_left", 20)
    margin3.add_theme_constant_override("margin_right", 20)
    margin3.add_theme_constant_override("margin_top", 10)
    margin3.add_theme_constant_override("margin_bottom", 20)
    vbox.add_child(margin3)

    var inner_hbox = HBoxContainer.new()
    inner_hbox.add_theme_constant_override("separation", 10)
    margin3.add_child(inner_hbox)

    var prev_btn = Button.new()
    prev_btn.text = "← 上一个"
    prev_btn.add_theme_font_size_override("font_size", 20)
    prev_btn.pressed.connect(_on_prev_class)
    inner_hbox.add_child(prev_btn)

    var next_btn = Button.new()
    next_btn.text = "下一个 →"
    next_btn.add_theme_font_size_override("font_size", 20)
    next_btn.pressed.connect(_on_next_class)
    inner_hbox.add_child(next_btn)

    var start_btn = Button.new()
    start_btn.text = "开始游戏"
    start_btn.add_theme_font_size_override("font_size", 36)
    start_btn.anchor_left = 0.5
    start_btn.anchor_right = 0.5
    start_btn.offset_left = -200
    start_btn.offset_right = 200
    start_btn.offset_top = 600
    start_btn.offset_bottom = 680
    start_btn.pressed.connect(_on_start)
    add_child(start_btn)

    message_label = Label.new()
    message_label.text = "WASD 移动 | 空格攻击 | 1/2/3 技能 | 4 大招"
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.add_theme_font_size_override("font_size", 20)
    message_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
    message_label.anchor_left = 0.5
    message_label.anchor_right = 0.5
    message_label.offset_left = -500
    message_label.offset_right = 500
    message_label.offset_top = 720
    message_label.offset_bottom = 760
    add_child(message_label)

func _on_prev_class():
    selected_class = (selected_class - 1 + 4) % 4
    _update_class_display()

func _on_next_class():
    selected_class = (selected_class + 1) % 4
    _update_class_display()

func _on_start():
    var file = FileAccess.open("user://class_save.txt", FileAccess.WRITE)
    if file:
        file.store_line(str(selected_class))
        file.close()
    get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func _update_class_display():
    if class_label:
        class_label.text = "职业: " + class_names[selected_class]
    if class_preview:
        class_preview.color = class_colors[selected_class]
