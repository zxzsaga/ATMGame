'use strict';

function Player(type, x, y, ghost, zombie, name, room, alive) {
    this.type = type || 'pos';
    this.x = x || -1;
    this.y = y || -1;
    this.ghost = ghost || false;
    this.zombie = zombie || false;
    this.name = name || '';
    this.alive = alive || false;
    // id
    // seed
    // room
}
exports.Player = Player;
