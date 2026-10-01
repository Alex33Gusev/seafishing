extends Node2D

var screen := "menu"
var caught := 0
var coins := 245
var rod := 1
var bait := 0
var hook := 0
var fishing := false
var bite := false
var paused := false
var tension := 35.0
var timer := 0.0
var rng := RandomNumberGenerator.new()
var status_text := ""

func _ready():
    rng.randomize()
    status_text = "Нажми ИГРАТЬ"
    queue_redraw()

func _process(delta):
    if screen == "fish" and not paused and fishing:
        timer -= delta
        if not bite and timer <= 0:
            bite = true
            status_text = "ПОКЛЁВКА! ЖМИ ПРОБЕЛ ИЛИ ВЫТАЩИТЬ"
        if bite:
            tension += rng.randf_range(-7, 10) * delta * 4
            tension = clamp(tension, 0, 100)
            if tension >= 96:
                status_text = "Леска лопнула — рыба ушла!"
                stop_fishing()
    queue_redraw()

func _draw():
    var s := get_viewport_rect().size
    if screen == "menu":
        draw_rect(Rect2(Vector2.ZERO, s), Color("#0b5279"))
        draw_circle(Vector2(s.x/2, s.y*0.82), s.x*0.55, Color("#0a6d96"))
        draw_string(ThemeDB.fallback_font, Vector2(s.x/2-235,130), "SEA FISHING", HORIZONTAL_ALIGNMENT_LEFT, -1, 64, Color("#ffffff"))
        draw_string(ThemeDB.fallback_font, Vector2(s.x/2-125,175), "МОРСКАЯ РЫБАЛКА", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#d8f5ff"))
        button(Rect2(s.x/2-190,235,380,70), "ИГРАТЬ")
        button(Rect2(s.x/2-190,325,380,70), "МАГАЗИН")
        button(Rect2(s.x/2-190,415,380,70), "НАСТРОЙКИ")
    else:
        draw_rect(Rect2(Vector2.ZERO,s), Color("#0b5874"))
        draw_rect(Rect2(0,s.y*0.60,s.x,s.y*0.40), Color("#07506d"))
        draw_string(ThemeDB.fallback_font, Vector2(35,75), "🐟 Рыба: %d / 10" % caught, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
        draw_string(ThemeDB.fallback_font, Vector2(s.x-220,75), "🪙 %d" % coins, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
        panel(Rect2(s.x/2-310,90,620,65), paused ? "ПАУЗА" : status_text)
        draw_rect(Rect2(35,190,25,230), Color("#152b38"))
        draw_rect(Rect2(35,190+230*(1-tension/100.0),25,230*tension/100.0), Color("#30d86a"))
        draw_string(ThemeDB.fallback_font, Vector2(75,315), "Натяжение: %d%%" % int(tension), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color.WHITE)
        button(Rect2(s.x/2-155,s.y-135,310,75), bite ? "ВЫТАЩИТЬ!" : "ЗАБРОСИТЬ")
        button(Rect2(25,s.y-70,190,48), "СНАРЯЖЕНИЕ")
        button(Rect2(230,s.y-70,165,48), "ПРИМАНКА")
        button(Rect2(s.x-210,s.y-70,185,48), "В МЕНЮ")

func button(r: Rect2, text: String):
    draw_rect(r, Color("#07517c"), true)
    draw_rect(r, Color("#e4b34a"), false, 3)
    draw_string(ThemeDB.fallback_font, r.position + Vector2(0, r.size.y/2+9), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 25, Color.WHITE)

func panel(r: Rect2, text: String):
    draw_rect(r, Color("#06243cdd"), true)
    draw_rect(r, Color("#4ab7e9"), false, 2)
    draw_string(ThemeDB.fallback_font, r.position + Vector2(0,40), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 21, Color.WHITE)

func _input(event):
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE and screen == "fish":
            screen = "menu"
            stop_fishing()
        elif event.keycode == KEY_SPACE and screen == "fish" and not paused:
            if bite: reel()
            else: cast()
        elif event.keycode == KEY_P and screen == "fish":
            paused = not paused
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        click(event.position)

func click(p: Vector2):
    var s := get_viewport_rect().size
    if screen == "menu":
        if Rect2(s.x/2-190,235,380,70).has_point(p):
            screen = "fish"
            status_text = "Нажми ЗАБРОСИТЬ или ПРОБЕЛ"
        elif Rect2(s.x/2-190,325,380,70).has_point(p):
            status_text = "Магазин: улучшения будут доступны в следующей версии"
        elif Rect2(s.x/2-190,415,380,70).has_point(p):
            status_text = "Настройки: P — пауза, ESC — меню"
    else:
        if Rect2(s.x/2-155,s.y-135,310,75).has_point(p):
            if bite: reel()
            else: cast()
        elif Rect2(s.x-210,s.y-70,185,48).has_point(p):
            screen = "menu"
            stop_fishing()
        elif Rect2(25,s.y-70,190,48).has_point(p):
            status_text = "Удочка: уровень %d" % rod
        elif Rect2(230,s.y-70,165,48).has_point(p):
            status_text = "Приманка: %s" % ("Золотая" if bait else "Обычная")

func cast():
    if fishing: return
    fishing = true
    bite = false
    tension = 35
    timer = rng.randf_range(1.2, 3.8) - (rod-1)*0.4 - bait*0.25
    status_text = "Приманка в воде... ждём поклёвку"

func reel():
    var chance := 0.68 + (rod-1)*0.12 + bait*0.1 + hook*0.08
    if rng.randf() < min(chance, 0.96):
        caught += 1
        var reward := rng.randi_range(20, 60)
        coins += reward
        status_text = "Поймано! +%d монет" % reward
    else:
        status_text = "Рыба сорвалась!"
    stop_fishing()

func stop_fishing():
    fishing = false
    bite = false
    tension = 35
