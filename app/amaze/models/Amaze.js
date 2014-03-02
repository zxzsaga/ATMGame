'use strict';

function Amaze(users, userNum, rooms) {
    this.users = users || {}; // user object array
    this.userNum = userNum || 0;
    this.rooms = rooms || {}; // room object array
}
Amaze.prototype.addUser = function(user) {
    if (this.users[user.id]) {
        throw new Error('user id already exist');
    }
    this.users[user.id] = user;
    this.userNum ++;
}
// TODO
Amaze.prototype.removeUser = function(user) {
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
Amaze.prototype.addRoom = function(roomId, room) {
    this.rooms[roomId] = room;
}
Amaze.prototype.userJoinRoom = function(userId, roomId) {
    this.rooms[roomId].addUser(userId);
    this.users[userId].room = roomId;
}
Amaze.prototype.sendMsg = function(userList, msg) {
    for (var i = 0; i < userList.length; i++) {
        var connect = this.users[userList[i]].connection;
        if (connect.writable) {
            connect.write(msg);
        }
        else {
            console.log("can not send message to user %s", userList[i]);
        }
    }
}
Amaze.prototype.userLeaveRoom = function(user) {
    var roomId = user.room;
    if (roomId === 0) {
        throw new Error('user ' + user.id + ' try to leave room 0');
    }
    else {
        this.rooms[roomId].removeUser(user.id);
        if (this.rooms[roomId].userIds.length === 0 ) {
            delete this.rooms[roomId];
        }
        else {
            this.rooms[roomId].owner = this.rooms[roomId].userIds[0];
        }
        user.room = 0;
    }
}
Amaze.prototype.checkUserInRoom = function(userId, roomId) {
    var userRoom = this.users[userId].room;
    if (userRoom != 0) {
        if (this.rooms[userRoom].userIds.indexOf(userId) != -1) {
            return true;
        }
    }
    return false;
}




Amaze.prototype.userDrop = function(user) {
    this.rooms[user.room].removeUser(user.id);
}
exports.Amaze = Amaze;

