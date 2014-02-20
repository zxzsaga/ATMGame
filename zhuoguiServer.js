var app = require('express')();
var server = require('http').createServer(app);
var config = require('./config').config;

server.listen(config.zhuogui.port);
console.log("zhuogui-server listen on: " + config.zhuogui.port);

app.get('/', function (req, res) {
    res.sendfile(__dirname + '/views/zhuogui.html');
});

var io = require('socket.io').listen(server);

io.sockets.on('connection', function(socket) {
    socket.emit('news', { hello: 'FrogEdi' });
    socket.on('news', function(data) {
        var res = {};
        for (var i in data) {
            res[i] = data[i] + ' hahaha';
        }
        socket.emit('news', res);
    });
});
