'use strict';

var express = require('express'), app = express();
var fs = require('fs');
var Log = require('log'), log = new Log('info');
var connect = require('connect'); // use for parse response body.
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
var seed = Math.floor(Math.random() * (100000 - 2 + 1) + 2);
var playerCode = 1;
var broadcastTime = 0;
var globalIp = {};
var monster = {};
var trap = {};

var socket = require('net').createServer(function(connect) {
    // log.info('connect: ' + ip);
    var ip = connect.remoteAddress;
    
    if (!user[ip]) {
        user[ip] = {};
        user[ip].player = {
            type: 'pos',
            id: playerCode,
            seed: seed,
            x: -1,
            y: -1,
            ghost: 0,
            zombie: 0,
            name: 0,
            room: 0,
            alive: 0,
        };
        playerCode += 1;
        user[ip].lastTime = broadcastTime;
        user[ip].id = user[ip].player.id;
        log.info('new user: ' + ip);
    }
    user[ip].connection = connect;
    user[ip].restTime = 10;
    user[ip].online = true;

    connect.on('end', function() {
        // user[ip].online = false;
        log.info('disconnect: ' + ip);
        // waitForReconnect(ip);
    });
    
    connect.on('error', function() {
        log.info('error: ' + ip);
    })
    connect.on('data', function(data) {
        try {
            var jsonData = JSON.parse(data);
            if (jsonData.type == 'drop') {
                console.log('drop: ' + ip);
                for (var i in user) {
                    if (i != ip) {
                        user[i].connection.write(JSON.stringify(data), 'utf8');
                    }
                }
                delete user[ip];
            }
            else if (jsonData.type == 'monster') {
                if (!monster[jsonData.id]) {
                    monster[jsonData.id] = {};
                }
                if (jsonData.trapremain == -1) {
                    for (var i in user) {
                        if (user[i].id == jsonData.id) {
                            for (var j in trap) {
                                user[i].connection.write(JSON.stringify(trap[j]), 'utf8');
                            }
                        }
                    }
                }
                monster[jsonData.id].convertCd = jsonData.convertCd;
                monster[jsonData.id].trapremain = jsonData.trapremain;
            }
            else if (jsonData.type == 'trap') {
                if (!trap[jsonData.id]) {
                    trap[jsonData.id] = {};
                }
                if (jsonData.x == -1) {
                    for (var i in user) {
                        if (user[i].id == jsonData.id) {
                            for (var j in trap) {
                                user[i].connection.write(JSON.stringify(trap[j]), 'utf8');
                            }
                        }
                    }
                }
                trap[jsonData.id].x = jsonData.x;
                trap[jsonData.id].y = jsonData.y;
            }
            else {
                // console.log(JSON.parse(data));
                user[ip].player = JSON.parse(data);
                user[ip].player.lastTime = broadcastTime;
            }
        }
        catch (err) {
            log.info('receive data error');
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
        if ((broadcastTime - user[i].lastTime) > 300) {
            return delete user[i];
        }
        var sendToUser = '';
        for (var j in user) {
            var retStr = user[i].player;
            if (i == j) {
                retStr.id = 0 - user[i].player.id;
            }
            user[i].connection.write(JSON.stringify(retStr), 'utf8');
            sendToUser += retStr;
        }
//        console.log('send to ' + i + ': ' + sendToUser);
    }
}
function timeout() {
    broadcast();
    broadcastTime ++;
    setTimeout(timeout, 30);
}
function waitForReconnect(ip) {
    if (user[ip].online === true) {
        return log.info('reconnect: ' + ip);
    }
    if (user[ip].restTime <= 0) {
        log.info('truly disconnect: ' + ip);
        return delete user[ip];
    }
    user[ip].restTime -= 1;
    log.info('wait ' + ip + ': ' + user[ip].restTime);
    setTimeout('waitForReconnect(' + ip + ')', 1000);
}
timeout();
