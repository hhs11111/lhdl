extends Area2D

@export var amount: int = 10
var _sprite: Sprite2D
var _bob_timer: float = 0.0
var _initial_y: float = 0.0
var _life: float = 30.0

func _ready():
    add_to_group("items")
    monitoring = true
    monitorable = true
    
    _sprite = Sprite2D.new()
    _sprite.centered = true
    add_child(_sprite)
    
    var texture = ImageTexture.create_from_image(_create_gold_image())
    _sprite.texture = texture
    
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 12
    collision.shape = circle
    add_child(collision)
    
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
    
    _initial_y = position.y

func _process(delta):
    _bob_timer += delta
    _sprite.position.y = sin(_bob_timer * 3.0) * 2.0
    
    _life -= delta
    if _life <= 0:
        queue_free()

func _on_body_entered(body: Node2D):
    if body.has_method("add_gold"):
        body.add_gold(amount)
        queue_free()

func _on_area_entered(area: Area2D):
    var parent = area.get_parent()
    if parent and parent.has_method("add_gold"):
        parent.add_gold(amount)
        queue_free()

func on_pickup(player: Node):
    if player.has_method("add_gold"):
        player.add_gold(amount)

func _create_gold_image() -> Image:
    var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    
    for y in range(24):
        for x in range(24):
            var cx = x - 12
            var cy = y - 12
            var dist = sqrt(cx * cx + cy * cy)
            
            if dist < 10:
                if dist < 6:
                    img.set_pixel(x, y, Color(1.0, 0.9, 0.2))
                elif dist < 8:
                    img.set_pixel(x, y, Color(1.0, 0.7, 0.1))
                else:
                    img.set_pixel(x, y, Color(0.8, 0.5, 0.0))
    
    img.set_pixel(9, 8, Color(1.0, 1.0, 0.8))
    img.set_pixel(10, 8, Color(1.0, 1.0, 0.8))
    
    return img
