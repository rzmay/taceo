module.exports = class {

	constructor() {
		this.index = 0;
		this.sequence = [];
		this.turn = 0
	}

	add(tap) {
		this.sequence.push(tap || ["short", "long", "swipe"][Math.floor(Math.random()*3)]);
	}

	begin(players) {

	}

	input(tap, player) {
		
	}

}