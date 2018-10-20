module.exports = class {

	constructor(game) {
		this.index = 0;
		this.sequence = [];
		this.turn = 1;
	}

	add(tap) {
		this.sequence.push(tap || ["short", "long", "swipe"][Math.floor(Math.random()*3)]);
	}

	begin(players) {
		for (var i = 1; i < players.length; i++) {
			players[i].emit("gameStart", {
				turn: this.turn,
			})
		}
	}

	input(player, tap) {
		if (tap === this.sequence[this.index]) {
			this.index++;

		}
	}

};