extends Node

var current_wave: int = 1
var wave_timer: float = 0.0
var spawn_interval: float = 2.0
var is_spawning: bool = true

func _physics_process(delta: float):
    if not is_spawning:
        return
    
    wave_timer += delta
    if wave_timer >= spawn_interval:
        wave_timer = 0.0
        emit_signal("spawn_enemy")

func start_wave(wave: int):
    current_wave = wave
    spawn_interval = max(0.5, 2.0 - wave * 0.1)
    is_spawning = true
    wave_timer = 0.0

func stop_spawning():
    is_spawning = false

signal spawn_enemy