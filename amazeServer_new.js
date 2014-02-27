'use strict';

var express = require('express'), app = express();
var fs = require('fs');
var Log = require('log'), log = new Log('info');
var server = require('http').createServer(app);
var log4js = require('log4js');
log4js.replaceConsole();

var User = require('./app/amaze/models/User').User;
var Player = require('./app/amaze/models/Player').Player;
var Amaze = require('./app/amaze/models/Amaze').Amaze;
var Room = require('./app/amaze/models/Room').Room;
var Msg = require('./app/amaze/models/Msg').Msg;

var amazeConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).amaze;

app.use(express.static(__dirname + '/public/' + amazeConfig.public));
app.set('views', __dirname + '/public/' + amazeConfig.public);
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);

app.listen(amazeConfig.port);
console.log('amaze-web-server liston on: ' + amazeConfig.port);

app.get('/', function(req, res) {
    res.render('Game.html');
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
        // TODO: amaze.removeUser(user);
        console.log('User %s disconnect, remove him from amaze.', user.id);
        connect.destroy();
    });

    connect.on('error', function(data) {
        // TODO
        console.log('Error: ' + user.id);
        console.log(data);
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
                            amaze.userJoinRoom(user.id, msg.room);
                            connect.write(JSON.stringify({ type: 'success' }));
                            var message = {
                                id: 0 - user.id,
                                info: 'status',
                                ping: user.ping,
                                host: amaze.rooms[user.room].owner === user.id,
                                ghost: user.player.ghost,
                                name: user.name,
                                type: 'room'
                            };
                            connect.write(JSON.stringify(message));
                            console.debug("user %s enter a new room %s.", user.id, msg.room);
                        }
                        else if (roomStatus === 'waiting') {
                            amaze.userJoinRoom(user.id, msg.room);
                            connect.write(JSON.stringify({ type: 'success' }));
                            var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                            var message = {
                                id: user.id,
                                info: 'status',
                                ping: user.ping,
                                host: amaze.rooms[user.room].owner === user.id,
                                ghost: user.player.ghost,
                                name: user.name,
                                type: 'room'
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
                                    name: amaze.users[roomMates[j]].name,
                                    type: 'room'
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
                        user.name = msg.name;
                        user.player.ghost = msg.ghost;
                        user.ping = msg.ping;
                        var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                        var message = {
                            id: user.id,
                            info: 'status',
                            ping: user.ping,
                            host: amaze.rooms[user.room].owner === user.id,
                            ghost: user.player.ghost,
                            name: user.name,
                            type: 'room'
                        };
                        amaze.sendMsg(roomMates, JSON.stringify(message));
                        message.id = 0 - message.id;
                        connect.write(JSON.stringify(message));
                        console.debug(user.id + ': change his status');
                    }
                }
                else if (msg.info === 'quit') {
                    var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                    var message = {
                        id: user.id,
                        info: 'quit',
                        ping: user.ping,
                        host: amaze.rooms[user.room].owner === user.id,
                        ghost: user.player.ghost,
                        name: user.name,
                        type: 'room'
                    };
                    amaze.sendMsg(roomMates, JSON.stringify(message));
                    message.id = 0 - message.id;
                    connect.write(JSON.stringify(message));
                    amaze.userLeaveRoom(user);
                    console.debug(user.id + ': quit room');
                }
                else if (msg.info === 'start') {
                    // TODO
                    if (amaze.checkUserInRoom(user.id)) {
                        if (amaze.rooms[user.room].owner != user.id) {
                            connect.write("{error:you are not the owner}");
                            console.debug("user %s try to start room %s",
                                          user.id, user.room);
                        }
                        else {
                            var roomMates = amaze.rooms[user.room].getRoomMates(user.id);

                            // from here

                            for (var k = 0; k < roomMates.length; k++) {
                                var message = {
                                    id: 0 - roomMates[k],
                                    info: 'start',
                                    ping: amaze.users[roomMates[k]].ping,
                                    host: amaze.rooms[user.room].owner === roomMates[k],
                                    ghost: amaze.users[roomMates[k]].player.ghost,
                                    name: amaze.users[roomMates[k]].name,
                                    type: 'room'
                                };
                                amaze.users[roomMates[k]].connection.write(JSON.stringify(message));
                            }
                            var message = {
                                id: 0 - user.id,
                                info: 'start',
                                ping: user.ping,
                                host: amaze.rooms[user.room].owner === user.id,
                                ghost: user.player.ghost,
                                name: user.name,
                                type: 'room'
                            };
                            // console.error(roomMates);
                            // amaze.sendMsg(roomMates, JSON.stringify(message));
                            
                            // message.id = 0 - message.id;
                            connect.write(JSON.stringify(message));
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
                // remove user
                console.log('drop: ' + user.id);
                var roomMate = amaze.rooms[user.room].userIds;
                var indexOfUserId = roomMate.indexOf(user.id);
                roomMate[indexOfUserId] = roomMate[roomMate.length - 1];
                roomMate.pop();
                amaze.sendMsg(roomMate, msg);
                amaze.removeUser(user);
                connect.destroy();
            }
            else if (msg.type == 'trap') {
                var trap = { x: msg.x, y: msg.y };
                amaze.rooms[user.room].traps.push(trap);
            }
            else if (msg.type == 'pos') {
                user.player.x = msg.x;
                user.player.y = msg.y;
                user.player.ghost = msg.ghost;
                user.player.zombie = msg.zombie;
                user.player.alive = msg.alive;
                user.lastTime = amaze.rooms[user.room].broadcastTime;
/*
                var roomMates = amaze.rooms[user.room].getRoomMates(user.id);
                var message = {
                    id: user.id,
                    x: user.player.x,
                    y: user.player.y,
                    ping: user.ping,
                    seed: amaze.rooms[user.room].seed,
                    ghost: user.player.ghost,
                    zombie: user.player.zombie,
                    name: user.name,
                    alive: user.player.alive,
                    type: 'pos',
                    room: user.room
                };
                amaze.sendMsg(roomMates, JSON.stringify(message));
                // console.error(roomMates);
                for (var k = 0; k < roomMates.length; k++) {
                    var otherMsg = {
                        id: roomMates[k],
                        x: amaze.users[roomMates[k]].player.x,
                        y: amaze.users[roomMates[k]].player.y,
                        ping: amaze.users[roomMates[k]].ping,
                        seed: amaze.rooms[user.room].seed,
                        ghost: amaze.users[roomMates[k]].player.ghost,
                        zombie: amaze.users[roomMates[k]].player.zombie,
                        name: amaze.users[roomMates[k]].name,
                        alive: amaze.users[roomMates[k]].player.alive,
                        type: 'pos',
                        room: amaze.users[roomMates[k]].room
                    }
                    connect.write(JSON.stringify(otherMsg));
                }
                message.id = 0 - message.id;
                connect.write(JSON.stringify(message));
*/
            }
        }
        console.log(amaze);
        for (var i in amaze.users) {
            console.debug('players:');
            console.debug(amaze.users[i].player);
        }
        for (var i in amaze.rooms) {
            console.debug('rooms:');
            console.debug(amaze.rooms[i].userIds);
        }
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
    // console.log('wahahahahahaha');
    for (var i in amaze.rooms) {
        if (amaze.rooms.status === 'playing') {
            var currentRoom = amaze.rooms[i];
            for (var j = 0; j < currentRoom.userIds.length; j++) {
                var currentUserId = currentRoom.userIds[j];
                var roomMates = currentRoom.getRoomMates(currentUserId);
                var message = {
                    id: user.id,
                    x: user.player.x,
                    y: user.player.y,
                    ping: user.ping,
                    seed: amaze.rooms[user.room].seed,
                    ghost: user.player.ghost,
                    zombie: user.player.zombie,
                    name: user.name,
                    alive: user.player.alive,
                    type: 'pos',
                    room: user.room
                };
                amaze.sendMsg(roomMates, JSON.stringify(message));
                message.id = 0 - message.id;
                amaze.users[currentUserId].connection.write(JSON.stringify(message));
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
                                player1.type = 'dead';
                                var msg = {};
                                for (var m in player1) {
                                    msg[m] = player1[m];
                                }
                                msg.id = amaze.users[currentRoom.userIds[j]].id;
                                msg.seed = currentRoom.seed;
                                msg.room = i;
                                for (var l = 0; l < currentRoom.userIds.length; l++) {
                                    amaze.users[currentRoom.userIds[l]].connection.write(JSON.stringify(msg));
                                }
                                player1.type = 'pos';
                            }
                        }
                    }
                }
            }
            if (!player1.ghost) {
                for (var k = 0; k < currentRoom.traps.length; k++) {
                    console.log('wajajaj');
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

