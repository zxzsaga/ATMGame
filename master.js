'use strict';

var spawn = require('child_process').spawn;

var webServer = spawn('node', ['webServer.js']);
//webServer.on('error', function(data) {
//    console.log(data);
//})
//console.log("pid: " + webServer.pid);
webServer.stdout.on('data', function(data) {
    console.log(data.toString());
});