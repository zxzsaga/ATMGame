'use strict';

var express = require('express'), app = express();
var fs = require('fs');
var Log = require('log'), log = new Log('info');
var server = require('http').createServer(app);

var amazeConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).amaze;

app.use(express.static(__dirname + '/public/' + amazeConfig.public));
app.set('views', __dirname + '/public/' + amazeConfig.public);
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);

app.listen(amazeConfig.port);
log.info('amaze-web-server liston on: ' + amazeConfig.port);

app.get('/', function(req, res) {
    res.render('Game.html');
});



var user = {};
var userCount = 0;
var monster = {};
var trap = [];
var broadcastTime = 0;
var seed = Math.floor(Math.random() * (100000 - 2 + 1) + 2);

var socket = require('net').createServer(function(connect) {
    userCount ++;
    var thisUser = userCount;
    user[thisUser] = {
        player: {
            type: 'pos',
            id: thisUser,
            seed: seed,
            x: -1,
            y: -1,
            ghost: false,
            zombie: false,
            name: '',
            room: 0,
            alive: false,
        },
        connection: connect,
        lastTime: broadcastTime
    }
    connect.on('end', function() {
        log.info('disconnect: ' + thisUser);
    });
    connect.on('error', function(data) {
        log.info('error: ' + thisUser);
        log.info(data);
    })
    connect.on('data', function(data) {
        try {
            data = JSON.parse(data);
            if (data.type == 'drop') {
                log.info('drop: ' + thisUser);
                for (var i in user) {
                    if (i != thisUser) {
                        user[i].connection.write(JSON.stringify(data));
                    }
                }
                delete user[thisUser];
            }
            else if (data.type == 'monster') {
                // Todo
            }
            else if (data.type == 'trap') {
                if (data.x == -1) {
                    for (var i in user) {
                        for (var j = 0; j < trap.length; j++) {
                            user[i].connection.write(JSON.stringify(trap[j]));
                        }
                    }
                }
                else {
                    trap.push(data);
                }
            }
            else if (data.type == 'pos') {
                // log.info(data);
                user[thisUser].player = data;
            }
            user[thisUser].lastTime = broadcastTime;
        }
        catch (err) {
            connect.write('server parse JSON error');
            log.info('receive data error');
            log.info(err);
        }
    })
});
socket.listen(amazeConfig.socketPort, function() {
    log.info('amaze-socket-server listen on: ' + amazeConfig.socketPort);
});

var sandbox = require('net').createServer(function(connection) { // 'connection' listener
    log.info('connect843: ' + connection.remoteAddress);
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
            var playerCopy = {};
            for (var k in user[j].player) {
                    playerCopy[k] = user[j].player[k];
                }
            if (i == j) {
                playerCopy.id = 0 - playerCopy.id;
            }
            // log.info(playerCopy);
            user[i].connection.write(JSON.stringify(playerCopy));
        }
    }
}

function broadcastTimeout() {
    for (var i in user) {
        if ((broadcastTime - user[i].lastTime) > 300) {
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
                    var playerCopy = {};
                    for (var k in user[i].player) {
                        playerCopy[k] = user[i].player[k];
                    }
                    playerCopy.type = 'dead';
                    for (var k in user) {
                        user[k].connection.write(JSON.stringify(playerCopy));
                    }
                }
            }
        }
        for (var j = 0; j < trap.length; j++) {
            var player2Pos = { x: trap[j].x, y: trap[j].y };
            if (checkBlockDistance(player1Pos, player2Pos, 4, 9)) {
                var trappedMsg = trap[j];
                for (var k in user) {
                    user[k].connection.write(JSON.stringify(trappedMsg));
                }
            }
        }
    }
    broadcast();
    broadcastTime ++;
    setTimeout(broadcastTimeout, 30);
}
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
broadcastTimeout();
