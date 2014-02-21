'use strict';

var fs = require('fs');
var cluster = require('cluster');
var webServer = require('./webServer');
var zhuoguiServer = require('./zhuoguiServer');

var config = JSON.parse(fs.readFileSync('config.json', 'utf8'));

if (cluster.isMaster) {
    //webServer.runWebServer(config.web);
    zhuoguiServer.runZhuoguiServer(config.zhuogui);
}
