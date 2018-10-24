var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

module.exports = function (io) {
	io.on('connection', function (socket) {
		console.log(socket.id + " connected.");
    socket.on('game', function (data) {
    	if (data.private === true) {
    		console.log(data.name + " (" + socket.id + ") created a private game with password " + data.password)
			} else {
    		console.log(data.name + " (" + socket.id + ") created a random game")
			}
		})
	});

	return router;
};
