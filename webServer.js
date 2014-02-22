'use strict';

var fs = require('fs');
var express = require('express'), app = express();
var connect = require('connect'); // use for parse response body.
var Log = require('log'), log = new Log('info');

var webConfig = JSON.parse(fs.readFileSync('config.json', 'utf8')).web;
var UserDAO = require('./app/DAO/UserDAO').UserDAO;

function run() {
    app.use(express.cookieParser());
    app.use(connect.urlencoded());
    app.use(connect.json());
    app.use(express.static(__dirname + '/public/' + webConfig.public));
    app.set('views', __dirname + '/public/' + webConfig.public);
    app.set('view engine', 'jade');
    // app.engine('html', require('ejs').renderFile);
    app.listen(webConfig.port);
    log.info('Web-server liston on: ' + webConfig.port);

    app.get('/', function(req, res) {
        if (req.cookies.accessId) {
            res.send('nihao!!!');
        }
        else {
            res.render('login');
        }
    });
    app.get('/register', function(req, res) {
        res.render('register.html');
    });

    app.post('/register', function(req, res) {
        var userdao = new UserDAO(webConfig.DB);
        userdao.create(req.param('username'), req.param('password'), function(err, doc) {
            if (err) {
                res.send({ error: "Username existed" });
            }
            else {
                res.redirect('/');
            }
        })
    });    
    app.post('/login', function(req, res) {
        if (req.param('username') == '') {
            res.redirect('/');
        }
        else if (req.param('password') == '') {
            res.redirect('/');
        }
        else {
            var userdao = new UserDAO(webConfig.DB);
            userdao.findOne(req.param('username'), function(err, doc) {
                if (err) {
                    res.render({ error: "User doesn't exist" });
                    // throw err;
                }
                else {
                    if (doc.password !== req.param('password')) {
                        res.send({ error: "password doesn't match" });
                    }
                    else {
                        res.cookie('accessId', req.param('username'), { maxAge: 86400000 });
                        res.redirect('/');
                    }
                }
            })
        }
    });
}
exports.run = run;
