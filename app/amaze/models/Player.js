'use strict';

function Player(x, y, ghost, zombie, name, alive, text) {
    this.x = x || -1;
    this.y = y || -1;
    this.ghost = ghost || false;
    this.zombie = zombie || false;
    this.name = name || 'hzgd';
    this.alive = alive || false;
    this.text = text || '普通人！';
    // type
    // id
    // seed
    // room
}
exports.Player = Player;
