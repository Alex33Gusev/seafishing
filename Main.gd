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
var status_text := "Нажми ИГРАТЬ"
var toast_text := ""
var toast_timer := 0.0

func _ready():
    rng.randomize()
    load_game()
    queue_redraw()

func _process(delta):
    if toast_timer > 0:
        toast_timer -= delta
    if screen == "fish" and not paused and fishing:
        timer -= delta
        if not bite and timer <= 0:
            bite = true
            status_text = "🐟 ПОКЛЁВКА! ЖМИ ВЫТАЩИТЬ!"
        if bite:
            tension += rng.randf_range(-7, 10) * delta * 4
            tension = clamp(tension, 0, 100)
            if tension >= 96:
                status_text = "Леска слишком натянута — рыба ушла!"
                stop_fishing()
    queue_redraw()

func _draw():
    var s := get_viewport_rect().size
    if screen == "menu": draw_menu(s)
    elif screen == "fish": draw_fish(s)
    elif screen == "shop": draw_shop(s)
    elif screen == "settings": draw_settings(s)
    if toast_timer > 0:
        panel(Rect2(s.x/2-240, s.y*0.78, 480, 58), toast_text)

func draw_menu(s: Vector2):
    draw_rect(Rect2(Vector2.ZERO, s), Color("#0b5279"))
    draw_circle(Vector2(s.x*0.50,s.y*0.88),s.x*0.60,Color("#0a6d96"))
    for i in range(10):
        draw_line(Vector2(0,s.y*0.68+i*14),Vector2(s.x,s.y*0.68+i*14),Color("#1688ac88"),2)
    draw_string(ThemeDB.fallback_font, Vector2(s.x/2-235,120), "SEA FISHING", HORIZONTAL_ALIGNMENT_LEFT, -1, 64, Color("#ffffff"))
    draw_string(ThemeDB.fallback_font, Vector2(s.x/2-110,160), "МОРСКАЯ РЫБАЛКА", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#d8f5ff"))
    button(Rect2(s.x/2-190,215,380,70), "ИГРАТЬ")
    button(Rect2(s.x/2-190,305,380,70), "МАГАЗИН")
    button(Rect2(s.x/2-190,395,380,70), "НАСТРОЙКИ")

func draw_fish(s: Vector2):
    draw_rect(Rect2(Vector2.ZERO,s),Color("#0b5874"))
    draw_rect(Rect2(0,s.y*0.56,s.x,s.y*0.44),Color("#07506d"))
    for i in range(8):
        draw_line(Vector2(0,s.y*0.62+i*20),Vector2(s.x,s.y*0.62+i*20),Color("#167c9b66"),2)
    draw_string(ThemeDB.fallback_font,Vector2(25,45),"🐟 Рыба: %d / 10" % caught,HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color.WHITE)
    draw_string(ThemeDB.fallback_font,Vector2(s.x-210,45),"🪙 %d" % coins,HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color.WHITE)
    panel(Rect2(s.x/2-310,65,620,62),paused?"ПАУЗА":status_text)
    draw_rect(Rect2(25,175,26,230),Color("#172b38"))
    draw_rect(Rect2(25,175+230*(1-tension/100.0),26,230*tension/100.0),Color("#30d86a"))
    draw_string(ThemeDB.fallback_font,Vector2(70,300),"Натяжение: %d%%" % int(tension),HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color.WHITE)
    button(Rect2(s.x/2-155,s.y-125,310,70),bite?"ВЫТАЩИТЬ!":"ЗАБРОСИТЬ")
    button(Rect2(20,s.y-65,185,45),"СНАРЯЖЕНИЕ")
    button(Rect2(220,s.y-65,165,45),"ПРИМАНКА")
    button(Rect2(s.x-205,s.y-65,180,45),"В МЕНЮ")

func draw_shop(s: Vector2):
    background_panel(s,"🛒 МАГАЗИН")
    panel(Rect2(s.x/2-300,100,600,48),"Баланс: %d 🪙" % coins)
    card(Rect2(s.x/2-360,175,220,200),"🎣 УДОЧКА II","+15% к шансу поклёвки","150 🪙")
    card(Rect2(s.x/2-110,175,220,200),"🪱 ЗОЛОТАЯ ПРИМАНКА","+10% к шансу","75 🪙")
    card(Rect2(s.x/2+140,175,220,200),"⚓ КРЮЧОК PRO","+8% к вываживанию","100 🪙")
    button(Rect2(s.x/2-150,420,300,60),"НАЗАД")

func draw_settings(s: Vector2):
    background_panel(s,"⚙ НАСТРОЙКИ")
    panel(Rect2(s.x/2-280,145,560,58),"Управление: мышь / ПРОБЕЛ / ESC / P")
    panel(Rect2(s.x/2-280,225,560,58),"Автосохранение: ВКЛ")
    panel(Rect2(s.x/2-280,305,560,58),"Звук: ВКЛ")
    button(Rect2(s.x/2-150,410,300,60),"НАЗАД")

func background_panel(s: Vector2,title: String):
    draw_rect(Rect2(Vector2.ZERO,s),Color("#06243c"))
    draw_string(ThemeDB.fallback_font,Vector2(s.x/2-190,75),title,HORIZONTAL_ALIGNMENT_LEFT,-1,42,Color.WHITE)

func button(r: Rect2,text: String):
    draw_rect(r,Color("#07517c"),true)
    draw_rect(r,Color("#e4b34a"),false,3)
    draw_string(ThemeDB.fallback_font,r.position+Vector2(0,r.size.y/2+8),text,HORIZONTAL_ALIGNMENT_CENTER,r.size.x,24,Color.WHITE)

func panel(r: Rect2,text: String):
    draw_rect(r,Color("#06243ced"),true)
    draw_rect(r,Color("#4ab7e9"),false,2)
    draw_string(ThemeDB.fallback_font,r.position+Vector2(0,r.size.y/2+7),text,HORIZONTAL_ALIGNMENT_CENTER,r.size.x,19,Color.WHITE)

func card(r: Rect2,title: String,desc: String,price: String):
    draw_rect(r,Color("#0a3b59"),true)
    draw_rect(r,Color("#4ab7e9"),false,2)
    draw_string(ThemeDB.fallback_font,r.position+Vector2(10,35),title,HORIZONTAL_ALIGNMENT_LEFT,r.size.x-20,19,Color.WHITE)
    draw_string(ThemeDB.fallback_font,r.position+Vector2(10,80),desc,HORIZONTAL_ALIGNMENT_LEFT,r.size.x-20,16,Color("#bfeeff"))
    draw_string(ThemeDB.fallback_font,r.position+Vector2(10,135),price,HORIZONTAL_ALIGNMENT_LEFT,r.size.x-20,20,Color("#ffe082"))
    draw_string(ThemeDB.fallback_font,r.position+Vector2(10,180),"Нажми 1 / 2 / 3",HORIZONTAL_ALIGNMENT_LEFT,r.size.x-20,14,Color("#ffffffaa"))

func _input(event):
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if screen != "menu": screen = "menu"; stop_fishing()
        elif screen == "fish" and event.keycode == KEY_SPACE and not paused:
            if bite: reel()
            else: cast()
        elif screen == "fish" and event.keycode == KEY_P:
            paused = not paused
        elif screen == "shop":
            if event.keycode == KEY_1: buy_rod()
            elif event.keycode == KEY_2: buy_bait()
            elif event.keycode == KEY_3: buy_hook()
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        click(event.position)

func click(p: Vector2):
    var s := get_viewport_rect().size
    if screen == "menu":
        if Rect2(s.x/2-190,215,380,70).has_point(p): screen="fish"; status_text="Нажми ЗАБРОСИТЬ или ПРОБЕЛ"
        elif Rect2(s.x/2-190,305,380,70).has_point(p): screen="shop"
        elif Rect2(s.x/2-190,395,380,70).has_point(p): screen="settings"
    elif screen == "fish":
        if Rect2(s.x/2-155,s.y-125,310,70).has_point(p):
            if bite: reel()
            else: cast()
        elif Rect2(s.x-205,s.y-65,180,45).has_point(p): screen="menu"; stop_fishing()
    elif screen == "shop":
        if Rect2(s.x/2-150,420,300,60).has_point(p): screen="menu"
        elif Rect2(s.x/2-360,175,220,200).has_point(p): buy_rod()
        elif Rect2(s.x/2-110,175,220,200).has_point(p): buy_bait()
        elif Rect2(s.x/2+140,175,220,200).has_point(p): buy_hook()
    elif screen == "settings":
        if Rect2(s.x/2-150,410,300,60).has_point(p): screen="menu"

func cast():
    if fishing: return
    fishing=true; bite=false; tension=35
    timer=max(0.5,rng.randf_range(1.2,3.8)-(rod-1)*0.4-bait*0.25)
    status_text="Приманка в воде... ждём поклёвку"

func reel():
    var chance=0.68+(rod-1)*0.12+bait*0.10+hook*0.08
    if rng.randf()<min(chance,0.96):
        var names=["Скумбрия","Тунец","Дорада","Сибас"]
        var fish_name=names[rng.randi_range(0,names.size()-1)]
        var reward=rng.randi_range(20,60)
        caught+=1; coins+=reward
        status_text="🎉 %s пойман! +%d 🪙" % [fish_name,reward]
        save_game()
    else: status_text="Рыба сорвалась!"
    stop_fishing()

func stop_fishing():
    fishing=false; bite=false; tension=35

func buy_rod():
    if rod>=2: toast("Удочка уже улучшена"); return
    if coins<150: toast("Не хватает монет"); return
    coins-=150; rod=2; save_game(); toast("🎣 Удочка улучшена!")

func buy_bait():
    if bait>=1: toast("Золотая приманка уже куплена"); return
    if coins<75: toast("Не хватает монет"); return
    coins-=75; bait=1; save_game(); toast("🪱 Приманка куплена!")

func buy_hook():
    if hook>=1: toast("Крючок уже улучшен"); return
    if coins<100: toast("Не хватает монет"); return
    coins-=100; hook=1; save_game(); toast("⚓ Крючок улучшен!")

func toast(t: String):
    toast_text=t; toast_timer=2.0

func save_game():
    var f=FileAccess.open("user://save.dat",FileAccess.WRITE)
    if f: f.store_var([caught,coins,rod,bait,hook])

func load_game():
    if not FileAccess.file_exists("user://save.dat"): return
    var f=FileAccess.open("user://save.dat",FileAccess.READ)
    if f:
        var d=f.get_var()
        if d is Array and d.size()>=5:
            caught=d[0]; coins=d[1]; rod=d[2]; bait=d[3]; hook=d[4]
