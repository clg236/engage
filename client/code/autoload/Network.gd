extends Node

var url = "ws://localhost:3000"
var myself = 1
var my_name = ''
var ws = null # empty var for WebSocketClient
var myID = null # 
var clients = {} # empty clients dict
var status = 'DISCONNECTED'
var my_address
var role

# signals
signal connection_changed
signal hand_raised(data)
signal hand_lowered(data)
signal called_upon(data)
signal new_player(data)



func _ready():
	pass

func _connect(address, name):
	my_address = address
	my_name = name
	print('connecting with address %s' % my_address)
	ws = WebSocketClient.new()
	ws.connect("connection_established", self, "_connection_established") 
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect_to_url(url)
	
func _connection_established(protocol):
	print("Connection established with protocol: ", protocol)
	status = 'CONNECTED TO SERVER'
	send_data({
		'command': 'login',
		'address': my_address,
		'name' : my_name
	})
	emit_signal("connection_changed")

func _connection_closed(m): # called on server closed
	get_tree().reload_current_scene()
	print(m)

func _connection_error(): # called when client disconnects abruptly
	pass

func _process(_delta):
	if ws == null:
		return
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		# we are connected, poll the server
		ws.poll()
	if ws.get_peer(myself).is_connected_to_host():
		# check for messages
		if ws.get_peer(myself).get_available_packet_count() > 0:
			var data = ws.get_peer(myself).get_packet()
			print('recieved data from the server %s' % data.get_string_from_ascii())
			parser(parse_json(data.get_string_from_ascii()))
			
func send_data(data):
	if ws.get_peer(myself).is_connected_to_host():
		print('sending %s' % data)
		var packet = to_json(data).to_utf8()
		ws.get_peer(myself).put_packet(packet)

func parser(packet):
	if typeof(packet) != 18:
		print('wrong packet data type')
		return
	
	if packet.command == "setID":
		myID = packet.data
	if packet.command == "login":
		if packet.data.role == 'admin':
			print('the server said we are logged in as an admin!')
			status = 'LOGGED IN'
			myID = packet.data.id
			role = 'admin'
			emit_signal("connection_changed")
		if packet.data.role == 'student':
			print('the server said we are logged in as a student!')
			status = 'LOGGED IN'
			myID = packet.data.id
			role = 'student'
			emit_signal("connection_changed")
		else:
			status = 'NOT AUTHORIZED'
			emit_signal("connection_changed")
			
	if packet.command == "new player":
		print('new player has joined', packet.data)
		clients[packet.data] = packet.data
		emit_signal('new_player', packet.data)
		
	if packet.command == "hand raised":
		emit_signal('hand_raised', packet.data)
		
	if packet.command == "hand lowered":
		emit_signal('hand_lowered', packet.data)
		
	if packet.command == "called upon":
		emit_signal('called_upon', packet.data)
