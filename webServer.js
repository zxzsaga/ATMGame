'use strict';

var express = require('express'), app = express();
var connect = require('connect'); // use for parse response body.
var Log = require('log'), log = new Log('info');

var UserDAO = require('./app/DAO/UserDAO').UserDAO;

function runWebServer(webConfig) {
    app.use(express.cookieParser());
    app.use(connect.urlencoded());
    app.use(connect.json());
    app.use(express.static(__dirname + '/public/' + webConfig.public));
    app.set('views', __dirname + '/public/' + webConfig.public);
    app.set('view engine', 'html');
    app.engine('html', require('ejs').renderFile);
    app.listen(webConfig.port);
    log.info('Web-server liston on: ' + webConfig.port);

    app.get('/', function(req, res) {
        res.render('login.html');
    });
    
    app.post('/login', function(req, res) {
        var userdao = new UserDAO(webConfig.DB);
        userdao.getPassword(req.param('username'), function(err, password) {
            if (err) {
                res.send({ error: "User doesn't exist" });
                // throw err;
            }
            else {
                if (password !== req.param('password')) {
                    res.send({ error: "password doesn't match" });
                }
                else {
                    res.cookie('accessId', req.param('username'), { maxAge: 10800, signed: true });
                }
            }
            console.log(password);
            res.redirect('/');
        })
    });
}
exports.runWebServer = runWebServer;
