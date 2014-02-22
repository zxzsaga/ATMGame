'use strict';
var fs = require('fs');
var Log = require('log'), log = new Log('info');
var express = require('express'), app = express();
var connect = require('connect'); // use for parse response body.
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

var zhuoguiConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).zhuogui;

function run() {
    app.use(express.cookieParser());
    app.use(connect.urlencoded());
    app.use(connect.json());
    app.use(express.static(__dirname + '/public/' + zhuoguiConfig.public));
    app.set('views', __dirname + '/public/' + zhuoguiConfig.public);
    app.set('view engine', 'html');
    app.engine('html', require('ejs').renderFile);
    server.listen(zhuoguiConfig.port);
    log.info('zhuoghui-server liston on: ' + zhuoguiConfig.port);

    app.get('/', function(req, res) {
        res.render('Game.html');
    });
    io.sockets.on('connection', function(socket) {
        log.info('connected!!!!!!');
        socket.emit('news', { hello: 'FrogEdi' });
        socket.on('news', function(data) {
            var res = {};
            for (var i in data) {
                res[i] = data[i] + ' hahaha';
            }
            socket.emit('news', res);
        });
    });
}
exports.run = run;
