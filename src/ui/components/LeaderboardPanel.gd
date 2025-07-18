extends Control
class_name LeaderboardPanel

## LeaderboardPanel – displays Top-10 scores updated from LeaderboardService

const MAX_ROWS := 10

@export var title_text: String = "TOP 10 SCORES"

var rows: Array[Label] = []

func _ready() -> void:
    _build_ui()
    _connect_service()
    _refresh()

func _build_ui() -> void:
    # Build simple VBox with title + rows
    var panel := Panel.new()
    add_child(panel)
    panel.anchor_left = 0
    panel.anchor_top = 0
    panel.anchor_right = 0
    panel.anchor_bottom = 0
    panel.offset_right = 220
    panel.offset_bottom = 300

    var vbox := VBoxContainer.new()
    panel.add_child(vbox)
    vbox.anchor_left = 0
    vbox.anchor_top = 0
    vbox.anchor_right = 1
    vbox.anchor_bottom = 1
    vbox.theme = null

    var title := Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", Color(1,1,0.8))
    vbox.add_child(title)

    for i in MAX_ROWS:
        var lbl := Label.new()
        lbl.text = "-"
        lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        lbl.add_theme_font_size_override("font_size", 14)
        lbl.add_theme_color_override("font_color", Color(0.9,0.9,0.9,1))
        vbox.add_child(lbl)
        rows.append(lbl)

func _connect_service() -> void:
    print("🔗 LeaderboardPanel connecting to service...")
    var svc = null
    
    if Engine.has_singleton("LeaderboardService"):
        print("✅ LeaderboardService found via Engine.has_singleton")
        svc = Engine.get_singleton("LeaderboardService")
    else:
        print("⚠️ LeaderboardService not found via Engine.has_singleton, trying direct access...")
        # Try direct access via /root/ path
        var root_lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
        if root_lbs:
            svc = root_lbs
            print("✅ Found LeaderboardService via /root/ path")
    
    if svc:
        print("✅ LeaderboardService found! Connecting to leaderboard_updated signal...")
        svc.leaderboard_updated.connect(_on_leaderboard, CONNECT_DEFERRED)
        print("📋 Current leaderboard size: ", svc.leaderboard.size())
    else:
        print("❌ LeaderboardService not accessible via any method")

func _refresh() -> void:
    print("🔄 LeaderboardPanel refreshing...")
    var svc = null
    
    if Engine.has_singleton("LeaderboardService"):
        svc = Engine.get_singleton("LeaderboardService")
    else:
        # Try direct access via /root/ path
        var root_lbs = get_tree().get_root().get_node_or_null("LeaderboardService")
        if root_lbs:
            svc = root_lbs
    
    if svc:
        print("📊 Loading leaderboard data, entries: ", svc.leaderboard.size())
        _update_rows(svc.leaderboard)
    else:
        print("❌ Could not access LeaderboardService for refresh")

func _on_leaderboard(board: Array) -> void:
    _update_rows(board)

func _update_rows(board: Array) -> void:
    # Ensure length up to MAX_ROWS
    for i in MAX_ROWS:
        var label := rows[i]
        if i < board.size():
            var entry = board[i]
            label.text = "%2d. %s – %d" % [i + 1, entry.get("name", "-"), entry.get("points", 0)]
        else:
            label.text = "%2d. -" % [i + 1] 