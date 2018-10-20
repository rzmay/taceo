var TapSequenceManager = require("./TapSequenceManager");

class Game {

	static gameIds = [];

	constructor(priv, pass) {
		if (priv === true) {
			this.name = Game.randomName();
			this.pass = pass;
			this.players = [];
		} else {
			this.name = Game.randomName();
			this.pass = "public";
			this.players = [];
		}
		this.sequenceManager = new TapSequenceManager()
	}

	join(player, pass) {
		if (pass === this.pass && this.players.length < 3) {
			this.players.push(player);
			if (this.players.length === 2) {
				this.sequenceManager.begin(this.players);
				player.emit("joinSuccess", {
					name: this.name,
					playerNumber: this.players.length
				})
			}
		} else {
			player.emit("joinFailure", {
				pass: (pass === this.pass),
				full: this.players.length > 2
			})
		}
	}

	static randomName() {
		var name = "game" + Math.random().toString(36).substr(2, 10);

		// If game with name already exists
		if (this.gameIds.contains(name)) {
			name = this.randomName()
		}
		this.gameIds.push(name);
		return name
	}

}

module.exports = Game;