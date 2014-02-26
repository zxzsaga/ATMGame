'use strict';

function Room(userIds, monsters, traps, broadcastTime, status, seed) {
    this.userIds = userIds || []; 
    this.monsters = monsters || {};
    this.traps = traps || [];
    this.broadcastTime = broadcastTime || 0;
    this.status = status || 'waiting'; // waiting, playing
    this.seed = seed || Math.floor(Math.random() * 100000);
    this.owner = '';
}

Room.prototype.addUser = function(userId) {
    if (this.userIds.length === 0) {
        this.owner = userId;
    }
    this.userIds.push(userId);
}
Room.prototype.removeUser = function(userId) {
    // TODO: if the user is monster ?
    var indexOfUserId = this.userIds.indexOf(userId);
    this.userIds[indexOfUserId] = this.userIds[this.userIds.length - 1];
    this.userIds.pop();
}

exports.Room = Room;
