extends Area2D

@export var amount: int = 10
var _sprite: Sprite2D
var _bob_timer: float = 0.0
var _life: float = 30.0

func _ready():
    add_to_group("items")
    monitoring = true
    monitorable = true
    
    _sprite = Sprite2D.new()
    _sprite.centered = true
    add_child(_sprite)
    
    var texture = ImageTexture.create_from_image(_create_exp_image())
    _sprite.texture = texture
    
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 12
    collision.shape = circle
    add_child(collision)
    
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _process(delta):
    _bob_timer += delta
    _sprite.position.y = sin(_bob_timer * 3.0) * 2.0
    _sprite.rotation += delta * 2.0
    
    _life -= delta
    if _life <= 0:
        queue_free()

func _on_body_entered(body: Node2D):
    if body.has_method("add_experience"):
        body.add_experience(amount)
        queue_free()

func _on_area_entered(area: Area2D):
    var parent = area.get_parent()
    if parent and parent.has_method("add_experience"):
        parent.add_experience(amount)
        queue_free()

func on_pickup(player: Node):
    if player.has_method("add_experience"):
        player.add_experience(amount)

func _create_exp_image() -> Image:
    var img = Image.create(20, 20, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    
    for y in range(20):
        for x in range(20):
            var cx = x - 10
            var cy = y - 10
            var dist = sqrt(cx * cx + cy * cy)
            
            if dist < 8:
                var brightness = 0.6 + (8.0 - dist) / 8.0 * 0.4
                img.set_pixel(x, y, Color(0.3 * brightness, 0.5 * brightness, 1.0, brightness))
    
    return img
