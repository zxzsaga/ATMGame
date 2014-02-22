var fs = require('fs');
var Log = require('log'), log = new Log('info');
var amazeConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).amaze;

function run() {
    var user = {};
    var seed = 1;
    var playerCode = 1;
    var globalIp = {};
    var server = require('net').createServer(function(connect) { // 'connection' listener
        log.info('connect: ' + ip);
        var ip = connect.remoteAddress;
        
        if (!user[ip]) {
            user[ip] = {};
            user[ip].player = { id: playerCode, x: seed, y: 0, name: 0 };
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
    server.listen(amazeConfig.port, function() {
        log.info('amaze-server listen on: ' + amazeConfig.port);
    });
    
    var server1 = require('net').createServer(function(connection) { // 'connection' listener
        log.info('connect843: ' + connection.remoteAddress);

        connection.on('data', function(data) {
            var str1 = "<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0";
            connection.end(str1, 'utf8');
        });
    });
    server1.listen(843, function() {
        log.info('amaze-server listen on: ' + 843);
    });

    function broadcast() {
        for (var i in user) {
            var sendToUser = '';
            for (var j in user) {
                if (i == j) {
                    var retStr = JSON.stringify({ id: 0 - user[i].player.id,
                                                  x: seed,
                                                  y: 0 - user[i].player.y,
                                                  name: 0
                                                });
                    user[i].connection.end(retStr, 'utf8');
                    sendToUser += retStr;
                }
                else {
                    user[i].connection.end(JSON.stringify(user[j].player), 'utf8');
                    sendToUser += JSON.stringify(user[j].player);
                }
            }
            console.log('send to ' + i + ': ' + sendToUser);
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
}

exports.run = run;
