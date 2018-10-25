var TapSequenceManager = require("./TapSequenceManager");

class Game {

	static gameIds = [];
	static all = {};

	constructor(priv, pass) {
		if (priv === true) {
			this.name = Game.randomName();
			this.private = true;
			this.pass = pass;
		} else {
			this.name = Game.randomName();
			this.private = false;
			this.pass = "public";
		}
		this.players = [];
		this.names = [];
		this.replayVotes = [0, 0];
		this.sequenceManager = new TapSequenceManager();
		// Add this game to the JSON of games
		Game.all[this.name] = this;
	}

	join(player, name, pass) {
		if (pass === this.pass && this.players.length < 3) {
			this.players.push(player);
			this.names.push(name);
			if (this.players.length === 2) {
				this.sequenceManager.begin(this.players, this.names);
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

	replayVote(player) {
		// Make sure vote is coming from one of the players
		for (var i = 0; i < this.players.length; i++) {
			if (this.players[i].id === player.id) {
				this.replayVotes[i] = 1;
				if (this.replayVotes[0] === 1 && this.replayVotes[1] === 1) {
					this.replay();
				}
			}
		}
	}

	replay() {
		// Reset sequence manager
		this.sequenceManager = new TapSequenceManager();
		this.sequenceManager.begin(this.players, this.names);

		// Reset replay votes
		this.replayVotes = [0, 0];
	}

	end() {
		// Called at end of game (player disconnect or game not replayed)

		// Remove from all games
		Game.all[this.name] = null;


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