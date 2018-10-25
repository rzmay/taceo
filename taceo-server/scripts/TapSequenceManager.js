module.exports = class {

	constructor() {
		this.index = 0;
		this.sequence = [];
		this.turn = 1;
		this.players = [];
	}

	add(tap) {
		this.sequence.push(tap || ["short", "long", "swipe"][Math.floor(Math.random()*3)]);
	}

	begin(players, nicknames) {
		for (var i = 0; i < players.length; i++) {
			players[i].emit("gameStart", {
				nickname: nicknames[-i + 1]
			});
		}
		this.players = players;
		players[turn].emit("turn", {});
	}

	input(player, tap) {
		var playerNum = 0;
		for (var i = 0; i < this.players.length; i++) {
			if (player.id === this.players[i].id) {
				playerNum = i;
			}
		}

		if (this.turn === playerNum) {
			// If player has completed sequence, add tap
			if (this.index === this.sequence.count) {
				this.add(tap);
				// Next player's turn
				turn = -turn + 1;
				setTimeout(function () {
					this.players[turn].emit("turn", {});
				}, 1250)
			// If player has not yet completed sequence, check consistency
			} else if (tap === this.sequence[this.index]) {
				// Handle correct tap
				this.index++;
			} else {
				// Handle incorrect tap, do not vibrate
				this.endGame();
				return null
			}
			// Send vibration to other player
			this.players[-playerNumber + 1].emit("vibrate", {
				tap: tap
			})
		}
	}

	endGame() {
		for (var i = 0; i < this.players.length; i++) {
			// If it was not this player's turn (when losing), they are the winner
			players[i].emit("gameEnd", {
				sequence: this.sequence,
				winner: (i !== turn)
			})
		}



	}

};