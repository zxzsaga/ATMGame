'use strict';

function Amaze(users, userNum, rooms) {
    this.users = users || {}; // user object array
    this.userNum = userNum || 0;
    this.rooms = rooms || {}; // room object array
}

Amaze.prototype.checkRoomStatus = function(roomId) {
    if (!this.rooms[roomId]) {
        return 'notExist';
    }
    else if (this.rooms[roomId].status === 'waiting') {
        return 'waiting';
    }
    else if (this.rooms[roomId].status === 'playing') {
        return 'playing';
    }
}
Amaze.prototype.addUser = function(user) {
    if (this.users[user.id]) {
        throw new Error('user id already exist');
    }
    this.users[user.id] = user;
    this.userNum ++;
}
Amaze.prototype.removeUser = function(user) {
    this.rooms[user.room].removeUser(user.id);
    delete this.users[user.id];
}
Amaze.prototype.userDrop = function(user) {
    this.rooms[user.room].removeUser(user.id);
}
Amaze.prototype.addRoom = function(roomId, room) {
    this.rooms[roomId] = room;
}
Amaze.prototype.checkUserInRoom = function(userId, roomId) {
    var userRoom = this.users[userId].room;
    if (userRoom != -1) {
        if (this.rooms[userRoom].userIds.indexOf(userId) != -1) {
            return true;
        }
        else return false;
    }
}
Amaze.prototype.userJoinRoom = function(userId, roomId) {
    this.rooms[roomId].addUser(userId);
    this.users[userId].joinRoom(roomId);
}
Amaze.prototype.sendMsg = function(userList, msg) {
    for (var i = 0; i < userList.length; i++) {
        var connect = users[userList[i]].connection;
        if (connect.writable) {
            this.users[userList[i]].connection.write(msg);
        }
        else {
            console.log("can not send message to user %s", userList[i]);
        }
    }
}
exports.Amaze = Amaze;
