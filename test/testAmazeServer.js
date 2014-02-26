var net = require('net');
var log4js = require('log4js');
log4js.replaceConsole();

var client = net.connect({ port: 23456 }, function() { //'connect' listener
    console.log('client connected');
    var msg = { type: 'joinRoom', room: 2 };
    client.write(JSON.stringify(msg));
    msg = { type: 'startRoom'};
    client.write(JSON.stringify(msg));
});
client.on('data', function(data) {
  console.log(data.toString());
  client.end();
});
client.on('end', function() {
  console.log('client disconnected');
});
