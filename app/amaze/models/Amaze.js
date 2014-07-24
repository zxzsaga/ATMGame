'use strict';

function Amaze(users, userNum, rooms) {
    this.users = users || {}; // user object array
    this.userNum = userNum || 0;
    this.rooms = rooms || {}; // room object array
}
Amaze.prototype.newUser = function(user) {
    user.id = this.getNewUserId();
    if (this.users[user.id]) {
        console.error('User id: %s already exist.' + user.id);
        return;
    }
    this.users[user.id] = user;
    this.usersNum ++;
};
Amaze.prototype.getNewUserId = function() {
    return this.userNum + 1;
};
Amaze.prototype.userLeaveRoom = function(user) {
    var userRoomId = user.room;
    if (!userRoomId) {
        console.error('User id: %s try to leave room %s', user.id, userRoomId);
        return;
    }
    var userRoom = this.rooms[userRoomId];
    if (!userRoom) {
        console.error('User id: %s want to leave room %s, but this room does not exist.',
            user.id, userRoomId
        );
        return;
    }
    var roomMates = userRoom.getRoomMates(user.id);
    var message = {
        id: user.id,
        info: 'quit',
        ping: user.ping,
        host: userRoom.owner === user.id,
        ghost: user.player.ghost,
        name: user.player.name,
        type: 'room'
    };
    this.sendMsg(roomMates, JSON.stringify(message));
    userRoom.removeUser(user.id);
    if (userRoom.userIds.length === 0) {
        delete this.rooms[userRoomId];
    } else {
        userRoom.owner = userRoom.userIds[0];
        var message2 = {
            type: 'host',
            id: userRoom.owner
        };
        this.sendMsg(roomMates, JSON.stringify(message2));
    }
    user.room = null;
    console.log(user.id + ': quit room %s.' + userRoomId);
};
Amaze.prototype.addRoom = function(roomId, room) {
    this.rooms[roomId] = room;
};
Amaze.prototype.addUser = function(user) {
    if (this.users[user.id]) {
        throw new Error('user id already exist');
    }
    this.users[user.id] = user;
    this.userNum ++;
};
// TODO
Amaze.prototype.removeUser = function(user) {
};
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
};
Amaze.prototype.userJoinRoom = function(userId, roomId) {
    this.rooms[roomId].addUser(userId);
    this.users[userId].room = roomId;
};
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
};
Amaze.prototype.checkUserInRoom = function(userId) {
    var userRoom = this.users[userId].room;
    if (userRoom != 0) {
        if (this.rooms[userRoom].userIds.indexOf(userId) != -1) {
            return true;
        }
    }
    return false;
};
module.exports = Amaze;

