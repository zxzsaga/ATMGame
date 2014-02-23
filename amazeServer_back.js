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
var userNum = 0;
var monster = {};
var trap = [];
var broadcastTime = 0;
// var keyToUser = {}; // { key: usernum }
var seed = Math.floor(Math.random() * (100000 - 2 + 1) + 2);

var socket = require('net').createServer(function(connect) {
//    var connectKey = connect.remoteAddress;
    userNum ++;
    if (!keyToUser[connectKey]) {
        userNum ++;
        keyToUser[connectKey] = userNum;
        user[keyToUser[connectKey]] = {};
        user[keyToUser[connectKey]].player = {
            type: 'pos',
            id: keyToUser[connectKey],
            seed: seed,
            x: -1,
            y: -1,
            ghost: false,
            zombie: false,
            name: '',
            room: 0,
            alive: false,
        };
        log.info('new user: ' + connectKey);
    }
    user[keyToUser[connectKey]].lastTime = broadcastTime;
    user[keyToUser[connectKey]].connection = connect;

    connect.on('end', function() {
        log.info('disconnect: ' + connectKey);
    });
    connect.on('error', function() {
        log.info('error: ' + connectKey);
    })
    connect.on('data', function(data) {
        try {
            data = JSON.parse(data);
            if (data.type == 'drop') {
                console.log('drop: ' + connectKey);
                for (var i in keyToUser) {
                    if (i != connectKey) {
                        user[keyToUser[i]].connection.write(JSON.stringify(data));
                    }
                }
                delete user[keyToUser[connectKey]];
                delete keyToUser[connectKey];
            }
            else if (data.type == 'monster') {
                /*
                if (!monster[data.id]) {
                    monster[data.id] = {};
                }
                if (data.trapremain == -1) {
                    for (var i in keyToUser) {
                        if (user[keyToUser[i]].player.id == data.id) {
                            for (var j in trap) {
                                user[keyToUser[i]].connection.write(JSON.stringify(trap[j]));
                            }
                        }
                    }
                }
                else {
                    monster[data.id].convertCd = data.convertCd;
                    monster[data.id].trapremain = data.trapremain;
                }
                */
            }
            else if (data.type == 'trap') {
                if (data.x == -1) {
                    for (var i in keyToUser) {
                        for (var j = 0; j < trap.length; j++) {
                            user[keyToUser[i]].connection.write(JSON.stringify(trap));
                        }
                    }
                }
                else {
                    trap.push(data);
                }
            }
            else if (data.type == 'pos') {
                //console.log(1);
                // console.log(JSON.parse(data));
                // console.log(data);
                user[keyToUser[connectKey]].player = data;
                //console.log(2);
            }
            user[keyToUser[connectKey]].lastTime = broadcastTime;
        }
        catch (err) {
            log.info('receive data error');
            console.log(data.toString());
            console.log(err);
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
    for (var i in keyToUser) {
        if ((broadcastTime - user[keyToUser[i]].lastTime) > 300) {
            delete user[keyToUser[i]];
            delete keyToUser[i];
        }
        else {
            var sendToUser = '';
            for (var j in keyToUser) {
                var retStr = {};
                for (var k in user[keyToUser[i]].player) {
                    retStr[k] = user[keyToUser[i]].player[k];
                }
                if (i == j) {
                    retStr.id = 0 - retStr.id;
                }
                user[keyToUser[j]].connection.write(JSON.stringify(retStr));
                sendToUser += JSON.stringify(retStr);
            }
            console.log('send to ' + i + ': ' + sendToUser);
        }
    }
}
function timeout() {
    for (var i in keyToUser) {
        var player1Pos = { x: user[keyToUser[i]].player.x, y: user[keyToUser[i]].player.y };
        for (var j in user) {
            var player2Pos = { x: user[j].player.x, y: user[j].player.y };
            if (!user[keyToUser[i]].player.ghost && user[j].player.zombie) {
                if (checkDistance(player1Pos, player2Pos, 15)) {
                    var retStr = {};
                    for (var k in user[keyToUser[i]].player) {
                        retStr[k] = user[keyToUser[i]].player[k];
                    }
                    retStr.type = 'dead';
                    for (var k in keyToUser) {
                        user[keyToUser[k]].connection.write(JSON.stringify(retStr));
                    }
                }
            }
        }
        for (var j = 0; j < trap.length; j++) {
            var player2Pos = { x: trap[j].x, y: trap[j].y };
            if (checkBlockDistance(player1Pos, player2Pos, 4, 9)) {
                var retStr = {};
                for (var k in user[keyToUser[i]].player) {
                    retStr[k] = user[keyToUser[i]].player[k];
                }
                retStr.type = 'trapped';
                for (var k in keyToUser) {
                    user[keyToUser[k]].connection.write(JSON.stringify(retStr));
                }
            }
        }
    }
    broadcast();
    broadcastTime ++;
    setTimeout(timeout, 30);
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
timeout();
