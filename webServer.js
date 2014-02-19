var express = require('express');
var connect = require('connect');
var config = require('./config').config;

var app = express();
app.use(connect.urlencoded());
app.use(connect.json());
app.use(express.static(__dirname + '/public'))
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);
app.listen(config.web.port);
console.log('Web-server liston on: ' + config.web.port);

app.get('/', function(req, res) {
    res.render('login.html');
});

app.post('/login', function(req, res) {
    console.log(req.param('username'));
    console.log(req.param('password'));
});

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
