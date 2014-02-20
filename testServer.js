require('net').createServer(function(socket) {
    console.log('connected');
    socket.on('data', function(data) {
        console.log(data.toString());
        // socket.write('hahahahahahaha,  a, hahahaa', 'utf8');
        socket.end('hahahahahahaha,  a, hahahaa', 'utf8');
    })
}).listen(23456);
console.log('running');
