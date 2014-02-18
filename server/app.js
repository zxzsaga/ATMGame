var fs = require('fs');
var express = require('express');
var connect = require('connect');

var config = JSON.parse(fs.readFileSync('config.json', 'utf8'));
var webServer = express();
webServer.use(connect.urlencoded());
webServer.use(connect.json());
webServer.use(express.static(__dirname + '/public'))
webServer.set('view engine', 'html');
webServer.engine('html', require('ejs').renderFile);

webServer.get('/', function(req, res) {
    res.render('login.html');
});

webServer.post('/login', function(req, res) {
    console.log(req.param('username'));
    console.log(req.param('password'));
});

webServer.listen(config.PORT);
console.log('Web-server liston on: ' + config.PORT);
/*
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

server.listen(3000);

app.get('/', function(req, res) {
    res.render('test');
    // res.render('index');
});

io.sockets.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});

app.post('/login', function(req, res) {
    console.log(req.body);
    res.json(req.body);
});

app.listen(config.PORT);
*/
