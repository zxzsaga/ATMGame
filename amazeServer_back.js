var fs = require('fs');
var Log = require('log'), log = new Log('info');
var amazeConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).amaze;
var http = require('http');

function run() {
    var ips = {};
    var seed = 1;
    var counter = 0;
    var server = require('net').createServer(function(connection) { // 'connection' listener
        // log.info('connect: ' + connection.remoteAddress);
        var thisConnection = connection;
        var thisIp = thisConnection.remoteAddress;
        
        if (!ips[thisIp]) {
            counter = counter + 1;
            ips[thisIp] = {};
            ips[thisIp].player = {};
            ips[connection.remoteAddress].connection = {};
            connection.end(JSON.stringify({ id: 0 - counter, x: seed, y: 0, name: 0}), 'utf8');
            console.log('new gamer: ' + connection.remoteAddress);
            //console.log(JSON.stringify({ id: 0 - counter, x: seed, y: 0, name: 0}));
        }
        ips[connection.remoteAddress].connection = connection;
        ips[connection.remoteAddress].restTime = 10;
        ips[connection.remoteAddress].online = true;

        connection.on('end', function() {
            ips[connection.remoteAddress].online = false;
            console.log('disconnect: ' + connection.remoteAddress);
            waitForReconnect(connection.remoteAddress);
            // log.info('disconnect');
        });
        
        connection.on('error', function() {
            // console.log('error: ' + connection.remoteAddress);
        })
        connection.on('data', function(data) {
            try {
                var jsonData = JSON.parse(data);
                console.log(JSON.parse(data));
                ips[connection.remoteAddress].player = JSON.parse(data);
                // connect.end('{id: 1, x: 0, y: 0, name: "wahaha"}', 'utf8');
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
        for (var i in ips) {
            var sendtoi = '';
            for (var j in ips) {
                if (i == j) {
                    ips[i].connection.end(JSON.stringify({id: 0 - ips[i].player.id, x: seed, y: 0, name: 0}), 'utf8');
                    sendtoi += JSON.stringify({id: 0 - ips[i].player.id, x: seed, y: 0, name: 0});
                }
                else {
                    ips[i].connection.end(JSON.stringify(ips[j].player), 'utf8');
                    sendtoi += JSON.stringify(ips[j].player);
                }
            }
            console.log('send to ' + i + ': ' + sendtoi);
        }
    }
    function timeout() {
        broadcast();
        setTimeout(timeout, 30);
    }
    function waitForReconnect(ip) {
        if (ips[ip].online === true) {
            return console.log('reconnect: ' + ip);
        }
        ips[ip].restTime -= 1;
        if (restTime <= 0) {
            console.log('truly disconnect: ' + ip);
            return delete (ips[ip]);
        }
        setTimeout(waitForReconnect(ip), 1000);
    }
    timeout();
}

exports.run = run;
