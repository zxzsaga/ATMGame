var net = require('net');
var log4js = require('log4js');
log4js.replaceConsole();



var client = net.connect(23456, function() { //'connect' listener
    console.log('client connected');
    var msg = { type: 'room', info: 'join', room: 1 };
    client.write(JSON.stringify(msg));
    //    msg = { type: 'room', info: 'status', name: 'hzgd', ghost: false, ping: 0};
    //    client.write(JSON.stringify(msg));
});
client.on('data', function(data) {
    console.log(data.toString());
});
client.on('end', function() {
    console.log('client disconnected');
});


var client2 = net.connect(23456, function() { //'connect' listener
    console.log('client connected');
    var msg = { type: 'room', info: 'join', room: 1 };
    client2.write(JSON.stringify(msg));
    msg = { type: 'room', info: 'status', name: 'hzgd', ghost: false, ping: 0};
    client.write(JSON.stringify(msg));
});
client2.on('data', function(data) {
    console.log(data.toString());
});
client2.on('end', function() {
    console.log('client disconnected');
});
