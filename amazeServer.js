// 'use strict';

var express = require('express'), app = express();
var connect = require('connect'); // use for parse response body.
var fs      = require('fs');
var Log     = require('log'), log = new Log('info');
var server  = require('http').createServer(app);
var log4js  = require('log4js');
log4js.replaceConsole();

var User   = require('./app/amaze/models/User').User;
var Player = require('./app/amaze/models/Player').Player;
var Amaze  = require('./app/amaze/models/Amaze').Amaze;
var Room   = require('./app/amaze/models/Room').Room;
var Msg    = require('./app/amaze/models/Msg').Msg;

var amazeConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).amaze;

app.use(express.cookieParser());
app.use(connect.urlencoded());
app.use(connect.json());
app.use(express.static(__dirname + '/public/' + amazeConfig.public));
app.set('views', __dirname + '/public/' + amazeConfig.public);
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);

app.listen(amazeConfig.port);
console.log('amaze-web-server liston on: ' + amazeConfig.port);
/*
app.all('*', function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "X-Requested-With");
    res.header("Access-Control-Allow-Methods","PUT,POST,GET,DELETE,OPTIONS");
    res.header("X-Powered-By",' 3.2.1')
    res.header("Content-Type", "application/text");
    next();
});
*/
app.get('/', function(req, res) {
    res.render('Game.html');
});
app.post('/getRooms', function(req, res) {
    var msg = {};
    msg.rooms = [];
    for (var z in amaze.rooms) {
        var room = {
            room: z,
            player: amaze.rooms[z].userIds.length,
            status: amaze.rooms[z].status
        }
        msg.rooms.push(room);
    }
    res.json(msg);
});


var amaze = new Amaze();
var socket = require('net').createServer(function(connect) {
    socket.bufferSize = 512;

    // TODO: 检查玩家是否为老玩家, 目前暂定 id 为 amaze.userNum + 1
    var id = amaze.userNum + 1;

    var user = new User(id, connect);
    var player = new Player();
    user.player = player; 
    amaze.addUser(user);
    console.log('New user id: %s connect.', user.id);

    connect.on('end', function() {
        if (user.room > 0) {
            var currentRoom = amaze.rooms[user.room];
            var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
            var message = {
                id: user.id,
                info: 'quit',
                ping: user.ping,
                host: amaze.rooms[user.room].owner === user.id,
                ghost: user.player.ghost,
                name: user.player.name,
                type: 'room'
            };
            amaze.sendMsg(roomMates, JSON.stringify(message));
            amaze.userLeaveRoom(user);
            console.debug(user.id + ': quit room');
            
            var message2 = {
                type: 'host',
                id: currentRoom.owner
            }
            amaze.sendMsg(roomMates, JSON.stringify(message2));
        }
        console.log('User %s disconnect, remove him from amaze.', user.id);
        connect.destroy();
    });

    connect.on('error', function(data) {
        if (user.room > 0) {
            var currentRoom = amaze.rooms[user.room];
            var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
            var message = {
                id: user.id,
                info: 'quit',
                ping: user.ping,
                host: amaze.rooms[user.room].owner === user.id,
                ghost: user.player.ghost,
                name: user.player.name,
                type: 'room'
            };
            amaze.sendMsg(roomMates, JSON.stringify(message));
            amaze.userLeaveRoom(user);
            console.debug(user.id + ': quit room');
            
            var message2 = {
                type: 'host',
                id: currentRoom.owner
            }
            amaze.sendMsg(roomMates, JSON.stringify(message2));
        }
        
        // TODO
        console.log('Error: ' + user.id);
        // console.log(data);
        connect.destroy();
    });

    connect.on('data', function(data) {
        var msgArr = new Msg(data);
        for (var i = 0; i < msgArr.msgs.length; i++) {
            try {
                var msg = JSON.parse(msgArr.msgs[i]);
            } catch(err) {
                /*
                  connect.write("{error:You sent the msg '"
                              + msgArr.msgs[i]
                              + "' can not be parse to JSON.}" );
                */
                console.debug(user.id + " send a msg can not be parsed to JSON");
                continue;
            }
            if (msg.type === 'ping') {
              connect.write(JSON.stringify(msg));
            }
            if (msg.type === 'chat') {
                var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                var message = {
                    type: 'chat',
                    name: user.player.name,
                    content: msg.content
                };
                amaze.sendMsg(roomMates, JSON.stringify(message));
                connect.write(JSON.stringify(message));
            }
            if (msg.type === 'gameChat') {
                var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                var message = {
                    type: 'gameChat',
                    name: user.player.name,
                    content: msg.content
                };
                amaze.sendMsg(roomMates, JSON.stringify(message));
                connect.write(JSON.stringify(message));
            }
            if (msg.type === 'room') {
                if (msg.info === 'join') {
                    if (!msg.hasOwnProperty('room')) {
                        connect.write(JSON.stringify({ type: 'failed' }));
                        console.debug("{error:'joinRoom' don't have or param 'room'}");
                    }
                    else {
                        var roomStatus = amaze.checkRoomStatus(msg.room);
                        if (roomStatus === 'notExist') {
                            var newRoom = new Room();
                            amaze.addRoom(msg.room, newRoom);
                            user.player.name = msg.name;
                            amaze.userJoinRoom(user.id, msg.room);
                            connect.write(JSON.stringify({ type: 'success' }));
                            var message = {
                                id: 0 - user.id,
                                info: 'status',
                                ping: user.ping,
                                host: amaze.rooms[user.room].owner === user.id,
                                ghost: user.player.ghost,
                                name: user.player.name,
                                type: 'room',
                                text: user.player.text
                            };
                            connect.write(JSON.stringify(message));
                            console.debug("user %s enter a new room %s.", user.id, msg.room);
                        }
                        else if (roomStatus === 'waiting') {
                            user.player.name = msg.name;
                            amaze.userJoinRoom(user.id, msg.room);
                            connect.write(JSON.stringify({ type: 'success' }));
                            var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                            var message = {
                                id: user.id,
                                info: 'status',
                                ping: user.ping,
                                host: amaze.rooms[user.room].owner === user.id,
                                ghost: user.player.ghost,
                                name: user.player.name,
                                type: 'room',
                                text: user.player.text
                            };
                            amaze.sendMsg(roomMates, JSON.stringify(message));
                            message.id = 0 - message.id;
                            connect.write(JSON.stringify(message));
                            for (var j = 0; j < roomMates.length; j++) {
                                var roomMateMsg = {
                                    id: roomMates[j],
                                    info: 'status',
                                    ping: amaze.users[roomMates[j]].ping,
                                    host: roomMates[j] === amaze.rooms[user.room].owner,
                                    ghost: amaze.users[roomMates[j]].player.ghost,
                                    name: amaze.users[roomMates[j]].player.name,
                                    type: 'room',
                                    text: amaze.users[roomMates[j]].player.text
                                }
                                connect.write(JSON.stringify(roomMateMsg));
                            }
                            console.debug("user %s enter room %s.", user.id, msg.room);
                        }
                        else if (roomStatus === 'playing') {
                            connect.write(JSON.stringify({ type: 'failed' }));
                            console.debug("user %s try to enter a playing room %s.",
                                        user.id, msg.room)
                        }
                    }
                }
                else if (msg.info === 'status') {
                    if (!(msg.hasOwnProperty('name') && msg.hasOwnProperty('ghost') && msg.hasOwnProperty('ping'))) {
                        connect.write(JSON.stringify({ type: 'failed' }));
                        console.debug('user change status lack of params');
                    }
                    else {
                        if (user.room && amaze.rooms[user.room]) {
                            user.player.name = msg.name;
                            user.player.ghost = msg.ghost;
                            user.ping = msg.ping;
                            user.player.text = msg.text;
                            var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                            var message = {
                                id: user.id,
                                info: 'status',
                                ping: user.ping,
                                host: amaze.rooms[user.room].owner === user.id,
                                ghost: user.player.ghost,
                                name: user.player.name,
                                type: 'room',
                                text: msg.text
                            };
                            amaze.sendMsg(roomMates, JSON.stringify(message));
                            message.id = 0 - message.id;
                            connect.write(JSON.stringify(message));
                            console.debug(user.id + ': change his status');
                        }
                    }
                }
                else if (msg.info === 'quit') {
                    var currentRoom = amaze.rooms[user.room];
                    var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                    var message = {
                        id: user.id,
                        info: 'quit',
                        ping: user.ping,
                        host: amaze.rooms[user.room].owner === user.id,
                        ghost: user.player.ghost,
                        name: user.player.name,
                        type: 'room'
                    };
                    amaze.sendMsg(roomMates, JSON.stringify(message));
                    message.id = 0 - message.id;
                    connect.write(JSON.stringify(message));
                    amaze.userLeaveRoom(user);
                    console.debug(user.id + ': quit room');
                    
                    var message2 = {
                        type: 'host',
                        id: currentRoom.owner
                    }
                    amaze.sendMsg(roomMates, JSON.stringify(message2));
                }
                else if (msg.info === 'start') {
                    if (amaze.checkUserInRoom(user.id)) {
                        if (amaze.rooms[user.room].owner != user.id) {
                            connect.write("{error:you are not the owner}");
                            console.debug("user %s try to start room %s",
                                          user.id, user.room);
                        }
                        else {
                            var currentRoom = amaze.rooms[user.room];
                            for (var j = 0; j < currentRoom.userIds.length; j++) {
                                var currentUser = amaze.users[currentRoom.userIds[j]];
                                var message = {
                                    id: currentUser.id,
                                    info: 'start',
                                    ping: currentUser.ping,
                                    host: currentUser.id === currentRoom.owner,
                                    ghost: currentUser.player.ghost,
                                    name: currentUser.player.name,
                                    type: 'room'
                                }
                                currentUser.connection.write(JSON.stringify(message));
                            }
                            amaze.rooms[user.room].status = 'playing';
                            console.debug(user.id + ': room playing');
                            
                        }
                    }
                    else {
                        connect.write("{error:user.room and room.user doesn't match}");
                        console.debug("user.room and room.user doesn't match");
                    }
                }
            }
            else if (msg.type === 'drop') {
                if (user.room > 0) {
                    var currentRoom = amaze.rooms[user.room];
                    var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                    var message = {
                        id: user.id,
                        info: 'quit',
                        ping: user.ping,
                        host: amaze.rooms[user.room].owner === user.id,
                        ghost: user.player.ghost,
                        name: user.player.name,
                        type: 'room'
                    };
                    amaze.sendMsg(roomMates, JSON.stringify(message));
                    amaze.userLeaveRoom(user);
                    console.debug(user.id + ': drop');                    
                }
                
                // TODO
                console.log('Error: ' + user.id);
                // console.log(data);
                connect.destroy();
            }
            else if (msg.type == 'trap') {
                var trap = { x: msg.x, y: msg.y };
                amaze.rooms[user.room].traps.push(trap);
                var message = {
                    type: 'trap',
                    x: trap.x,
                    y: trap.y
                }
                amaze.rooms[user.room].userIds.forEach(function(userId) {
                    amaze.users[userId].connection.write(JSON.stringify(message));
                    // console.log('trap: ' + userId);
                });
            }
            else if (msg.type == 'pos') {
                user.player.x = msg.x;
                user.player.y = msg.y;
                user.player.ghost = msg.ghost;
                user.player.zombie = msg.zombie;
                user.player.alive = msg.alive;
                user.lastTime = amaze.rooms[user.room].broadcastTime;
            }
            else if (msg.type == 'win') {
                // name === human
                console.log(msg);
                var currentRoom = msg.room;
                var roomPlayerIds = amaze.rooms[currentRoom].userIds;
                var message = {
                    type: 'win',
                    name: 'human'
                }
                console.log(roomPlayerIds);
                amaze.sendMsg(roomPlayerIds, JSON.stringify(message));
                amaze.rooms[currentRoom].status = 'waiting';
                function newRoom() {
                    for (var k = 0; k < roomPlayerIds.length; k++) {
                        var currentPlayerId = roomPlayerIds[k];
                        amaze.users[currentPlayerId].connection.destroy();
                        delete amaze.users[currentPlayerId];
                    }
                    amaze.rooms[currentRoom] = new Room();
                }
                setTimeout(newRoom, 1000);
            }
        }
        /*
        console.log(amaze);
        for (var i in amaze.users) {
            console.debug('players:');
            console.debug(amaze.users[i].player);
        }
        for (var i in amaze.rooms) {
            console.debug('rooms:');
            console.debug(amaze.rooms[i].userIds);
        }
        */
    });

});
socket.listen(amazeConfig.socketPort, function() {
    log.info('amaze-socket-server listen on: ' + amazeConfig.socketPort);
});
var sandbox = require('net').createServer(function(connection) {
    // console.debug('connect to 843: ' + connection.remoteAddress);
    connection.on('data', function(data) {
        var str1 = "<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0";
        connection.end(str1, 'utf8');
    });
});
sandbox.listen(amazeConfig.sandboxPort, function() {
    log.info('amaze-sandbox-server listen on: ' + amazeConfig.sandboxPort);
});

// TODO: 每30毫秒告诉房间里的人
function broadcast() {
    for (var i in amaze.rooms) {
        if (amaze.rooms[i].status === 'playing') {
            var currentRoom = amaze.rooms[i];
            for (var j = 0; j < currentRoom.userIds.length; j++) {
                var currentUserId = currentRoom.userIds[j];
                var currentUser = amaze.users[currentUserId];
                var roomMates = currentRoom.getRoomMates(currentUserId);
                var message = {
                    id: currentUserId,
                    x: currentUser.player.x,
                    y: currentUser.player.y,
                    ping: currentUser.ping,
                    seed: currentRoom.seed,
                    ghost: currentUser.player.ghost,
                    zombie: currentUser.player.zombie,
                    name: currentUser.player.name,
                    alive: currentUser.player.alive,
                    type: 'pos',
                    room: i
                };
                amaze.sendMsg(roomMates, JSON.stringify(message));
                message.id = 0 - message.id;
                currentUser.connection.write(JSON.stringify(message));
            }
        }
    }
}

function broadcastTimeout() {
    for (var i in amaze.rooms) {
        if (amaze.rooms[i].status === 'waiting') {
            continue;
        }
        var currentRoom = amaze.rooms[i];
        for (var j = 0; j < currentRoom.userIds.length; j++) {
            var player1 = amaze.users[currentRoom.userIds[j]].player;
            var player1Pos = { x: player1.x, y: player1.y };
            for (var k = 0; k < currentRoom.userIds.length; k++) {
                if (j != k) {
                    var player2 = amaze.users[currentRoom.userIds[k]].player;
                    var player2Pos = { x: player2.x, y: player2.y };
                    if (!player1.ghost && player2.zombie) {
                        if (checkDistance(player1Pos, player2Pos, 12)) {
                            if (player1.alive && player2.alive) {
                                var msg = {};
                                for (var m in player1) {
                                    msg[m] = player1[m];
                                }
                                msg.id = amaze.users[currentRoom.userIds[j]].id;
                                msg.seed = currentRoom.seed;
                                msg.room = i;
                                msg.type = 'dead';
                                for (var l = 0; l < currentRoom.userIds.length; l++) {
                                    amaze.users[currentRoom.userIds[l]].connection.write(JSON.stringify(msg));
                                }
                                player1.alive = false;

                                var mans = currentRoom.userIds;
                                var flag = false;
                                for (var l = 0; l < mans.length; l++) {
                                    var currentMan = mans[l];
                                    console.debug(currentMan);
                                    if (amaze.users[currentMan].player.ghost === false && amaze.users[currentMan].player.alive === true) {
                                        flag = true;
                                        break;
                                    }
                                }
                                if (flag === false) {
                                    var roomPlayerIds = currentRoom.userIds;
                                    var message = {
                                        type: 'win',
                                        name: 'ghost'
                                    }
                                    amaze.sendMsg(roomPlayerIds, JSON.stringify(message));
                                    currentRoom.status = 'waiting';
                                    function newRoom() {
                                        for (var l = 0; l < roomPlayerIds.length; l++) {
                                            var currentPlayerId = roomPlayerIds[l];
                                            amaze.users[currentPlayerId].connection.destroy();
                                            delete amaze.users[currentPlayerId];
                                        }
                                        amaze.rooms[i] = new Room();
                                    }
                                    setTimeout(newRoom, 1000);
                                }
                            }
                        }
                    }
                }
            }
            if (!player1.ghost) {
                for (var k = 0; k < currentRoom.traps.length; k++) {
                    var trap = currentRoom.traps[k];
                    var trapPos = { x: trap.x, y: trap.y };
                    if (checkBlockDistance(player1Pos, trapPos, 4, 9)) {
                        var trappedMsg = trap;
                        currentRoom.traps[k] = currentRoom.traps[currentRoom.traps.length - 1];
                        currentRoom.traps.pop();
                        trappedMsg.type = 'trapped';
                        for (var l = 0; l < currentRoom.userIds.length; l++) {
                            amaze.users[currentRoom.userIds[l]].connection.write(JSON.stringify(trappedMsg));
                        }

                    }
                }
            }
        }
        currentRoom.broadcastTime ++;
    }
    broadcast();
    setTimeout(broadcastTimeout, 30);
}
broadcastTimeout();




function checkDistance(pos1, pos2, limit) {
    if ((pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.y - pos2.y) * (pos1.y - pos2.y) < limit * limit) {
        return true;
    }
    return false;
}
function checkBlockDistance(pos1, pos2, edge1, edge2) {
    if (Math.max(pos1.x, pos2.x) <= Math.min(pos1.x + edge1, pos2.x + edge2)) {
        if (Math.max(pos1.y, pos2.y) <= Math.min(pos1.y + edge1, pos2.y + edge2)) {
            return true;
        }        
    }
    return false;
}
