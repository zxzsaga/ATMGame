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
    console.log('New user, id: %s connect.', user.id);
    
    connect.on('data', function(data) {
        var msgArr = new Msg(data);
        for (var i = 0; i < msgArr.msgs.length; i++) {
            try {
                var msg = JSON.parse(msgArr.msgs[i]);
            } catch(err) {
                connect.write("{error:You sent the msg '"
                              + msgArr.msgs[i]
                              + "' can not be parse to JSON.}" );
                continue;
            }

            if (msg.type === 'joinRoom') {
                // ignore msg.id
                if (!msg.room) {
                    connect.write("{error:'joinRoom' don't have or param 'room'}");
                }
                else {
                    var roomStatus = amaze.checkRoomStatus(msg.room);
                    if (roomStatus === 'notExist') {
                        var newRoom = new Room();
                        amaze.addRoom(msg.room, newRoom);
                        amaze.userJoinRoom(user.id, msg.room);
                        console.log("user %s enter a new room %s.", user.id, msg.room);
                    }
                    else if (roomStatus === 'waiting') {
                        amaze.userJoinRoom(user.id, msg.room);
                        console.log("user %s enter room %s.", user.id, msg.room);
                    }
                    else if (roomStatus === 'playing') {
                        connect.write("{error:this room is playing now.}");
                        console.log("user %s try to enter a playing room %s.",
                                    user.id, msg.room)
                    }
                }
            }
            if (msg.type === 'startRoom') {
                if (amaze.checkUserInRoom(user.id)) {
                    if (amaze.rooms[user.room].owner != user.id) {
                        connect.write("{error:you are not the owner}");
                        console.debug("user %s try to start room %s",
                                      user.id, user.room);
                    }
                    else {
                        amaze.rooms[user.room].status = 'playing';
                    }
                }
                else {
                    connect.write("{error:user.room and room.user doesn't match}");
                    console.debug("user.room and room.user doesn't match");
                }
            }
            if (msg.type === 'drop') {
                console.log('drop: ' + user.id);
                var roomMate = amaze.rooms[user.room].userIds;
                var indexOfUserId = roomMate.indexOf(user.id);
                roomMate[indexOfUserId] = roomMate[roomMate.length - 1];
                roomMate.pop();
                amaze.sendMsg(roomMate, msg);
                amaze.removeUser(user);
                connect.destroy();
            }
            else if (msg.type == 'monster') {
                // TODO
            }
            else if (msg.type == 'trap') {
                // TODO
                if (msg.x == -1) {
                    for (var i in user) {
                        for (var j = 0; j < trap.length; j++) {
                            user[i].connection.write(JSON.stringify(trap[j]));
                        }
                    }
                }
                else {
                    trap.push(msg);
                }
            }
            else if (msg.type == 'pos') {
                // log.info(JSON.stringify(data));
                user[thisUser].player = data;
                user[thisUser].lastTime = broadcastTime;
            }
        }
    });

    connect.on('end', function() {
        //console.debug(amaze.users);
        //console.debug(amaze.userNum);
        //console.debug(amaze.rooms);
        //amaze.userDrop(user);
        console.log('Disconnect: ' + user.id);
        connect.destroy();
    });
    connect.on('error', function(data) {
        console.log('Error: ' + user.id);
        console.log(data);
        connect.destroy();
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

function broadcast() {
    for (var i in user) {
        for (var j in user) {
            if (i == j) {
                user[j].player.id = 0 - user[j].player.id;
                user[i].connection.write(JSON.stringify(user[j].player));
                user[j].player.id = 0 - user[j].player.id;
            }
            else {
                user[i].connection.write(JSON.stringify(user[j].player));
            }
        }
    }
}

function broadcastTimeout() {
    for (var i in user) {
        if ((broadcastTime - user[i].lastTime) > 1800) {
            log.info('kick: ' + i);
            delete user[i];
        }
    }
    for (var i in user) {
        var player1Pos = { x: user[i].player.x, y: user[i].player.y };
        for (var j in user) {
            var player2Pos = { x: user[j].player.x, y: user[j].player.y };
            if (!user[i].player.ghost && user[j].player.zombie) {
                if (checkDistance(player1Pos, player2Pos, 15)) {
                    if (user[i].player.alive && user[j].player.alive) {
                        user[i].player.type = 'dead';
                        for (var k in user) {
                            user[k].connection.write(JSON.stringify(user[i].player));
                        }
                        user[i].player.type = 'pos';
                    }
                }
            }
        }
        if (!user[i].player.ghost) {
            for (var j = 0; j < trap.length; j++) {
                var player2Pos = { x: trap[j].x, y: trap[j].y };
                if (checkBlockDistance(player1Pos, player2Pos, 4, 9)) {
                    var trappedMsg = trap[j];
                    trap[j] = trap[trap.length - 1];
                    trap.pop();
                    trappedMsg.type = 'trapped';
                    for (var k in user) {
                        user[k].connection.write(JSON.stringify(trappedMsg));
                    }
                }
            }
        }
    }
    broadcast();
    broadcastTime ++;
    setTimeout(broadcastTimeout, 30);
}
// broadcastTimeout();






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
