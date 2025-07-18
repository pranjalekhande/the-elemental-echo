extends Node

## NetworkManager – minimal LAN host/join helper (Tier-2 scope)
# Responsibilities
# 1. Start server (host) or connect to one (client).
# 2. Keep mapping of `peer_id → player name` for the current session.
# 3. Provide simple RPCs for registering a player and submitting a score.
# 4. Emit local signals so UI or other singletons can react.
# NOTE: Real leaderboard handling lives in LeaderboardService (next milestone).

signal peer_registered(peer_id: int, name: String)
signal peer_left(peer_id: int)

# Default ENet configuration
const DEFAULT_PORT: int = 4321
const MAX_PEERS: int = 32

# Session state
var is_host: bool = false
var player_name: String = ""
var players: Dictionary = {} # peer_id → name

func _ready() -> void:
	# Autoload nodes are created on engine start; nothing to do yet.
	pass

# ---------------------------
# Public API
# ---------------------------
func set_player_name(name: String) -> void:
	"""Store the local player name before hosting / joining."""
	player_name = name.strip_edges()

func start_host(port: int = DEFAULT_PORT) -> void:
	"""Create an ENet server and become the session host."""
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PEERS)
	if err != OK:
		push_error("❌ Failed to start host: %s" % str(err))
		return

	multiplayer.multiplayer_peer = peer
	is_host = true

	# Host registers itself with peer ID 1
	players[1] = player_name if player_name != "" else "Host"
	print("✅ Hosting on port %d as '%s'" % [port, players[1]])

	_connect_signals()

func join(ip_address: String, port: int = DEFAULT_PORT) -> void:
	"""Connect to an existing host."""
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip_address, port)
	if err != OK:
		push_error("❌ Failed to connect: %s" % str(err))
		return

	multiplayer.multiplayer_peer = peer
	is_host = false

	_connect_signals()

	# Wait for `connected_to_server` below before registering name.

func submit_score(points: int) -> void:
	"""Send final score to host. Host will handle leaderboard update."""
	if multiplayer.multiplayer_peer == null:
		push_warning("submit_score called but not connected to multiplayer peer")
		return

	if is_host:
		_on_score_submitted(1, player_name, points)  # host submits directly
	else:
		rpc_id(1, "_rpc_submit_score", player_name, points)

# ---------------------------
# Multiplayer signal handlers
# ---------------------------
func _connect_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(func(): push_error("Connection failed"))

func _on_peer_connected(id: int) -> void:
	if is_host:
		# Newly connected peers will send their name via RPC after handshake.
		print("🔌 Peer connected: ", id)

func _on_peer_disconnected(id: int) -> void:
	print("⚠️ Peer disconnected: ", id)
	players.erase(id)
	peer_left.emit(id)

func _on_connected_to_server() -> void:
	print("✅ Connected to host. Registering name…")
	if player_name == "":
		player_name = "Player_%d" % multiplayer.get_unique_id()
	rpc_id(1, "_rpc_register_name", player_name)

# ---------------------------
# RPCs (always received by host)
# ---------------------------
@rpc("any_peer", "reliable")
func _rpc_register_name(name: String) -> void:
	"""Client → Host: register chosen player name."""
	if not is_host:
		return  # Only host should execute this body
	var sender_id := multiplayer.get_remote_sender_id()
	players[sender_id] = name
	print("👤 Registered peer %d as '%s'" % [sender_id, name])
	peer_registered.emit(sender_id, name)

@rpc("any_peer", "reliable")
func _rpc_submit_score(name: String, points: int) -> void:
	"""Client → Host: submit final score for leaderboard."""
	if not is_host:
		return
	var sender_id := multiplayer.get_remote_sender_id()
	_on_score_submitted(sender_id, name, points)
	# Notify LeaderboardService dynamically to avoid hard reference
	if is_host and Engine.has_singleton("LeaderboardService"):
		var lbs = Engine.get_singleton("LeaderboardService")
		lbs.call("add_score", name, points)

# ---------------------------
# Internal helpers
# ---------------------------
func _on_score_submitted(sender_id: int, name: String, points: int) -> void:
	# For now just log; LeaderboardService will consume in next milestone.
	print("🏅 Score submitted by '%s' (%d): %d points" % [name, sender_id, points]) 
