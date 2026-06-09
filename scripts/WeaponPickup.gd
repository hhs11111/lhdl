extends Area2D

@export var attack_bonus: int = 5
@export var rarity: int = 0
var _sprite: Sprite2D
var _bob_timer: float = 0.0
var _life: float = 60.0

func _ready():
    add_to_group("items")
    monitoring = true
    monitorable = true
    
    _sprite = Sprite2D.new()
    _sprite.centered = true
    add_child(_sprite)
    
    var texture = ImageTexture.create_from_image(_create_weapon_image())
    _sprite.texture = texture
    
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 14
    collision.shape = circle
    add_child(collision)
    
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _process(delta):
    _bob_timer += delta
    _sprite.position.y = sin(_bob_timer * 2.0) * 3.0
    _sprite.rotation = sin(_bob_timer * 1.5) * 0.3
    
    _life -= delta
    if _life <= 0:
        queue_free()

func _on_body_entered(body: Node2D):
    if body.has_method("equip_weapon"):
        body.equip_weapon(attack_bonus)
        print("获得武器！攻击力 +", attack_bonus)
        queue_free()

func _on_area_entered(area: Area2D):
    var parent = area.get_parent()
    if parent and parent.has_method("equip_weapon"):
        parent.equip_weapon(attack_bonus)
        print("获得武器！攻击力 +", attack_bonus)
        queue_free()

func on_pickup(player: Node):
    if player.has_method("equip_weapon"):
        player.equip_weapon(attack_bonus)

func _create_weapon_image() -> Image:
    var img = Image.create(28, 28, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    
    var colors = [
        [Color(0.8, 0.8, 0.8), Color(0.5, 0.5, 0.5)],
        [Color(0.5, 1.0, 0.5), Color(0.3, 0.7, 0.3)],
        [Color(0.5, 0.7, 1.0), Color(0.3, 0.5, 0.8)],
        [Color(0.8, 0.5, 1.0), Color(0.6, 0.3, 0.8)],
        [Color(1.0, 0.8, 0.2), Color(0.8, 0.6, 0.0)]
    ]
    
    var color_pair = colors[min(rarity, colors.size() - 1)]
    var main_color = color_pair[0]
    var edge_color = color_pair[1]
    
    for y in range(4, 24):
        for x in range(12, 16):
            img.set_pixel(x, y, main_color)
    
    for y in range(4, 24):
        img.set_pixel(11, y, edge_color)
        img.set_pixel(16, y, edge_color)
    
    for y in range(24, 28):
        for x in range(10, 18):
            img.set_pixel(x, y, Color(0.5, 0.35, 0.2))
    
    for y in range(0, 4):
        for x in range(13, 15):
            img.set_pixel(x, y, edge_color)
    
    return img
