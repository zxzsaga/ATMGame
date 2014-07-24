'use strict';

function Player(name, x, y, ghost, zombie, alive, text) {
    this.name = name || 'hzgd';
    this.x = x || -1;
    this.y = y || -1;
    this.ghost = ghost || false;
    this.zombie = zombie || false;
    this.alive = alive || false;
    this.text = text || '普通人！';
    // type
    // id
    // seed
    // room
}
module.exports = Player;
