let bodyParser = require('body-parser');
let db = require('./database');

module.exports = {};

module.exports.cors = cors;

module.exports.json = bodyParser.json();

module.exports.all = notImplemented;

module.exports.one = notImplemented;

module.exports.create = notImplemented;

module.exports.tick = tick;

module.exports.delete = notImplemented;

function cors(req, res, next)
{
	res.set(
		'Access-Control-Allow-Origin', '*'
	);

	next();
}

function notImplemented(req, res, next)
{
	res.sendStatus(501);
}

function tick(req, res, next)
{
	if (req.body.action === "tick")
	{
		notImplemented(req, res, next);
	}
	else
	{
		next();
	}
}