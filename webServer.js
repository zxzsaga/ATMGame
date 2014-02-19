var fs = require('fs');
var express = require('express');
var connect = require('connect');
var config = require('./config').config;
var UserDAO = require('./app/DAO/UserDAO');

var app = express();
app.use(connect.urlencoded());
app.use(connect.json());
app.use(express.static(__dirname + '/public'))
// app.set('views', __dirname + '/public')
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);
app.listen(config.web.port);
console.log('Web-server liston on: ' + config.web.port);
// console.log(express.static);

app.get('/', function(req, res) {
/*
    fs.readFile('./amaze/bin-release/Game.html', 'utf8', function(err, page) {
        if (err) {
            console.log(err);
            process.exit(1);
        }
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.write(page);
        res.end();
    });
*/
    res.render('amaze/bin-release/Game.html');
    // res.render('login.html');
});

app.post('/login', function(req, res) {
    UserDAO.getPassword(req.param('username'), function(err, password) {
        if (err) {
            throw err;
        }
        console.log(password);
    })
});
