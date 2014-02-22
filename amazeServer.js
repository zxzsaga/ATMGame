'use strict';

var express = require('express'), app = express();
var fs = require('fs');
var Log = require('log'), log = new Log('info');
var connect = require('connect'); // use for parse response body.
var server = require('http').createServer(app);

var amazeConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).amaze;

app.use(express.cookieParser());
app.use(connect.urlencoded());
app.use(connect.json());
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
var globalIp = {};
var socket = require('net').createServer(function(connect) {
    // log.info('connect: ' + ip);
    var ip = connect.remoteAddress;
    
    if (!user[ip]) {
        user[ip] = {};
        user[ip].player = {
            type: 'pos',
            id: playerCode,
            x: seed,
            y: 0,
            ghost: 0,
            zombie: 0,
            key: 0,
            name: 0,
            room: 0,
            alive: 0
        };
        playerCode += 1;
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
            console.log(JSON.parse(data));
            user[ip].player = JSON.parse(data);
        }
        catch (err) {
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
        var sendToUser = '';
        for (var j in user) {
            if (i == j) {
                var retStr = JSON.stringify(
                    {
                        type: user[i].player.type,
                        id: 0 - user[i].player.id,
                        x: seed,
                        y: user[i].player.y,
                        ghost: user[i].player.ghost,
                        zombie: user[i].player.zombie,
                        key: user[i].player.key,
                        name: user[i].player.name,
                        room: user[i].player.room,
                        alive: user[i].player.alive
                    }
                );
                user[i].connection.write(retStr, 'utf8');
                sendToUser += retStr;
            }
            else {
                user[i].connection.write(JSON.stringify(user[j].player), 'utf8');
                sendToUser += JSON.stringify(user[j].player);
            }
        }
//        console.log('send to ' + i + ': ' + sendToUser);
    }
}
function timeout() {
    
    broadcast();
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
