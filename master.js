'use strict';

var fs = require('fs');
var cluster = require('cluster');
var webServer = require('./webServer');
var zhuoguiServer = require('./zhuoguiServer');
var amazeServer = require('./amazeServerDevelopment');

var config = JSON.parse(fs.readFileSync('config.json', 'utf8'));

if (cluster.isMaster) {
    // webServer.run();
    amazeServer.run();
    zhuoguiServer.run();
}
