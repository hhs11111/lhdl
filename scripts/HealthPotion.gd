extends Area2D

@export var amount: int = 20
var animation_player: AnimationPlayer

func _ready():
    animation_player = $AnimationPlayer
    add_to_group("items")
    animation_player.play("float")

func _on_body_entered(body: Node2D):
    if body.is_in_group("players"):
        if body.has_method("heal"):
            body.heal(amount)
        queue_free()

func on_pickup(player: Node2D):
    if player.has_method("heal"):
        player.heal(amount)