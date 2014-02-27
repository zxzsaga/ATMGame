'use strict';

function Room(userIds, monsters, traps, broadcastTime, status, seed) {
    this.userIds = userIds || []; 
    this.monsters = monsters || {};
    this.traps = traps || [];
    this.broadcastTime = broadcastTime || 0;
    this.status = status || 'waiting'; // waiting, playing
    this.seed = seed || Math.floor(Math.random() * 100000);
    this.owner = 0;
}
Room.prototype.addUser = function(userId) {
    if (this.userIds.length === 0) {
        this.owner = userId;
    }
    this.userIds.push(userId);
}
Room.prototype.getRoomMates = function(userId) {
    var roomMates = [];
    for (var i = 0; i < this.userIds.length; i++) {
        roomMates.push(this.userIds[i]);
    }
    var indexOfId = roomMates.indexOf(userId);
    if (indexOfId != -1) {
        roomMates[indexOfId] = roomMates[roomMates.length - 1];
        roomMates.pop();
        return roomMates;
    }
    else {
        throw new Error ("userId: " + userId + " can not find his room");
    }
}
Room.prototype.removeUser = function(userId) {
    var indexOfUserId = this.userIds.indexOf(userId);
    this.userIds[indexOfUserId] = this.userIds[this.userIds.length - 1];
    this.userIds.pop();
}
exports.Room = Room;
// finished
