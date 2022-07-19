import { WebSocketServer } from "ws";
import { v4 as uuidv4 } from 'uuid';

const wss = new WebSocketServer({port: 3000})

let CLIENTS = {}
const STATE = {
    normal: 'normal',
    discussion: 'discussion',
    poll: 'poll',
    quiz: 'quiz'
}

let state = STATE.normal
console.log('our state is currently', state)

let users = [
    {
        'id': 0,
        'address': '1',
        'role' : 'ADMIN'
    },
    {
        'id' : 1,
        'address': '2',
        'role': 'STUDENT'
    },
    {
        'id' : 2,
        'address': '3',
        'role': 'STUDENT'
    },
    {
        'id' : 3,
        'address': '4',
        'role': 'STUDENT'
    }
]

// NEW CONNECTION
wss.on('connection', ws => {
    ws.id = uuidv4()
    // they just connected, so they're alive and well
    ws.isAlive = true

    console.log('a player has joined...', ws.id)
    CLIENTS[ws.id] = {
        'ws': ws,
        'id': ws.id
    }

    ws.on('message', message => {
        message = message.toString();
        message = message.replace(/[^A-Za-z 0-9 \.,\?""!@#\$%\^&\*\(\)-_=\+;:<>\/\\\|\}\{\[\]`~]*/g, '')
        if (message.indexOf('{') !== 0) { 
			message = message.substring(message.indexOf('{'))
		}

        // convert our message to JSON
        var obj = JSON.parse(message);

        // here is our command parser

        // LOGIN
        if(obj.command === "login"){
            // using javascript promises b/c boss (this should look in a db at some point)
            let loginPromise = new Promise((resolve, reject) => {
                users.filter((user) => {
                    if(user.address == obj.address) {
                        console.log(obj.name)
                        CLIENTS[ws.id]['name'] = obj.name
                        resolve(user.role)
                    } 
                })
            })

            loginPromise.then((result) => {
                if (result == 'ADMIN') {
                    console.log('we will log in as admin')
                    
                    // add to our client object
                    CLIENTS[ws.id]['role'] = 'admin'

                    // tell their client they are ok and an admin
                    var reply = {
                        "command":"login",
                        "data": {
                            'id': ws.id,
                            'role': 'admin',
                            'name': CLIENTS[ws.id]['name']
                        }
                    }
                }
    
                if (result == 'STUDENT') {
                    console.log('we will log in as a student')
                    CLIENTS[ws.id]['role'] = 'admin'
                    // tell their client they are ok and an student
                    var reply = {
                        "command":"login",
                        "data": {
                            'id': ws.id,
                            'role': 'student'
                        }
                    }
                }
                ws.send(JSON.stringify(reply))

                //update the client list on connected clients
                console.log('our connected clients: ', Object.keys(CLIENTS).length)
                for (const [key, client] of Object.entries(CLIENTS)) {
                    let reply = {
                        "command": "new player",
                        "data" : Object.keys(CLIENTS).length
                    }

                    client.ws.send(JSON.stringify(reply))
                    console.log('sending client info:', reply)
                }
            }).catch(error => console.log(error))

  
		}

        // STATE CHANGE
        if(obj.command == "state changed") {
            console.log('state has been changed to', obj.state)
        }

        // RAISE HAND
        if(obj.command == "hand") {
            let name = CLIENTS[obj.id]['name']
            let id = CLIENTS[obj.id]['id']
            if (obj.raised) {
                // who raised their hand?
                console.log(obj.id)

                // send the raised hand to everyone so they know the state of the room
                for (const [key, client] of Object.entries(CLIENTS)) {
                    
                    let reply = {
                        "command":"hand raised",
                        "data": {
                            "name":name,
                            "id": id
                        }

                    }
                    client.ws.send(JSON.stringify(reply))
                }
               
                console.log(name, 'raised their hands')
            } else {
                //send the lowered hand to everyone
                for (const [key, client] of Object.entries(CLIENTS)) {
                    let reply = {
                        "command":"hand lowered",
                        "data": {
                            "name":name,
                            "id": id
                        }

                    }
                    client.ws.send(JSON.stringify(reply))
                }
                console.log(name, 'lowered their hands')
            }
            
        }

        // CALL UPON YE!
        if(obj.command == "call upon") {

            // send the called upon client a message
            for (const [key, client] of Object.entries(CLIENTS)) {
                if (client.id == obj.data) {
                    console.log('calling upon', client.id)
                    let reply = {
                        "command": "called upon",
                        "data" : true
                    }
                    console.log('sending to client', client.id)
                    client.ws.send(JSON.stringify(reply))
                }
            }
        }

        // DISMISS THE HAND
        if(obj.command == "dismiss") {
            // send the called the dismissed message
            for (const [key, client] of Object.entries(CLIENTS)) {
                if (client.id == obj.data) {
                    let reply = {
                        "command": "called upon",
                        "data" : false
                    }
                    client.ws.send(JSON.stringify(reply))
                }
            
            }
        }

        // SEND A COMMENT
        if(obj.command == "comment") {
            console.log(obj.id, 'has sent a comment: ', obj.data)
        }

    });
})