'use strict';
var fs = require('fs');
var Log = require('log'), log = new Log('info');
var express = require('express'), app = express();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

var zhuoguiConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).zhuogui;

app.use(express.static(__dirname + '/public/' + zhuoguiConfig.public));
app.set('views', __dirname + '/public/' + zhuoguiConfig.public);
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);

server.listen(zhuoguiConfig.port);
log.info('zhuoghui-server liston on: ' + zhuoguiConfig.port);

app.get('/', function(req, res) {
    res.render('index.html');
});




var room = {};
var player = {};
var socketPlayer {}; // key, value

io.sockets.on('connection', function(socket) {
    socket.on('whoAmI', function(data));
    socket.on('createRoom', function(data) { // { username, number }
        if (!data.username) {
            socket.emit('msg', { error: 'please enter username' });
        }
        else if (!data.number) {
            socket.emit('msg', { error: 'please enter room number' });
        }
        else if (room[data.number]) {
            socket.emit('msg', { error: 'this room already exist' });
        }
        else {
            room[data.number] = {
                status: 'waiting',
                player: {},
                host: data.username,
                word: {
                    human: '毛线',
                    idiot: '锤子'
                }
            };
            room[data.number].player[data.username] = {};
            room[data.number].player[data.username].status = 'waiting';
            room[data.number].host = data.username;
            player[data.username] = {};
            player[data.username].room = data.number;
            socket.emit('msg', { success: 'create room' });
        }
    });
    socket.on('enterRoom', function(data) { // { username, number }
        if (!data.username) {
            socket.emit('msg', { error: 'please enter username' });
        }
        else if (!data.number) {
            socket.emit('msg', { error: 'please enter room number' });
        }
        else if (!room[data.number]) {
            socket.imit('msg', { error: 'this room does not exist' });
        }
        else if (room[data.number].player[data.username]) {
            socket.imit('msg', { error: 'this name already exist'});
        }
        else {
            room[data.number].player[data.username] = {};
            room[data.number].player[data.username].status = 'waiting';
            player[data.username] = {};
            player[data.username].room = data.number;
            socket.emit('msg', { success: 'enter room' });
        }
    });
    socket.on('ready', function() {
        if (player[data.])
    })
});
