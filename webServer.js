'use strict';

//var spawn = require('child_process').spawn;
var fs = require('fs');
var express = require('express'), app = express();
var connect = require('connect'); // use for parse response body.
var Log = require('log'), log = new Log('info');

var webConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).web;
var UserDAO = require('./app/DAO/UserDAO').UserDAO;

//var amazeServer;

app.use(express.cookieParser());
app.use(connect.urlencoded());
app.use(connect.json());
app.use(express.static(__dirname + '/public/' + webConfig.public));
app.set('views', __dirname + '/public/' + webConfig.public);
app.set('view engine', 'jade');
app.listen(webConfig.port);
log.info('Web-server liston on: ' + webConfig.port);


app.get('/', function(req, res) {
    if (req.cookies.accessId) {
        res.render('main', { username: req.cookies.accessId, cmd: 'run' });
    }
    else {
        res.redirect('/login');
    }
});
app.get('/login', function(req, res) {
    res.render('login');
})
app.get('/register', function(req, res) {
    res.render('register');
});
app.get('/account', function(req, res) {
    res.render('account');
})


app.post('/login', function(req, res) {
    if (req.param('username') == '') {
        res.render('login', { error: 'Please input username' });
    }
    else if (req.param('password') == '') {
        res.render('login', { error: 'Please input password' });
    }
    else {
        var userdao = new UserDAO(webConfig.DB);
        userdao.findOne(req.param('username'), function(err, doc) {
            if (err) {
                res.render('login', { error: 'Error when find user' });
            }
            else {
                if (doc === null) {
                    res.render('login', { error: "User doesn't exist" });
                }
                else if (doc.password !== req.param('password')) {
                    res.render('login', { error: "Password doesn't match" });
                }
                else {
                    res.cookie('accessId', req.param('username'), { maxAge: 86400000 });
                    res.redirect('/');
                }
            }
        })
    }
});
app.post('/register', function(req, res) {
    var userdao = new UserDAO(webConfig.DB);
    userdao.create(req.param('username'), req.param('password'), function(err, doc) {
        if (err) {
            res.render('register', { error: "Username existed" });
        }
        else {
            res.redirect('/');
        }
    })
});
app.post('/password', function(req, res) {
    if (req.param('password') == '') {
        res.render('account', { error: 'Please input password' });
    }
    else if (req.param('confirmPassword') == '') {
        res.render('account', { error: 'Please input password again' });
    }
    else if (req.param('password') != req.param('confirmPassword')) {
        res.render('account', { error: 'Password does not match' })
    }
    else {
        var userdao = new UserDAO(webConfig.DB);
        userdao.update(req.cookies.accessId, req.param('password'), function(err, doc) {
            if (err) {
                res.render('account', { error: 'Database error' });
            }
            else {
                res.render('account', { status: 'Success' });
            };
        })
    }
})
