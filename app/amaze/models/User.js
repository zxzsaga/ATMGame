'use strict';

function User(connection, id, ping, lastTime, room, status, player) {
    this.connection = connection;
    this.id = id;
    this.ping = ping || 0;
    this.lastTime = lastTime;
    this.room = room || null;
    this.status = status;
    this.player = player || {};
}



// TODO: need change
User.prototype.getBroadcastMsg = function(amaze) {
    var msg = [];
    var roomMateIds = amaze.rooms[this.room].userIds;
    for (var i = 0; i < roomMateIds.length; i++) {
        var roomMate = amaze.users[roomMateIds[i]];
        var playerInfo = this.getPlayerInfo;
        if (roomMate.id == this.id) {
            playerInfo.id = 0 - playerInfo.id;
        }
        msg.push(JSON.stringify(playerInfo));
    }
    return msg;
}
User.prototype.getPlayerInfo = function() {
    var playerInfo = {};
    for (var i in this.player) {
        playerInfo[i] = this.player[i];
    }
    playerInfo.id = this.id;
    playerInfo.seed = amaze.rooms[this.room].seed;
    playerInfo.room = this.room;
    return playerInfo;
}

module.exports = User;
