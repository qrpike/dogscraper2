

# Requires
EventEmitter = require('events').EventEmitter
request = require('request')
lodash = require('lodash')
async = require('async')
fs = require('fs')
mongoose = require('mongoose')
Schemas = require('./schemas/schemas.js')




# Connect to DB:
mongoose.connect('mongodb://localhost/pedigree')

# Base URL:
baseUrl = 'https://www.pedigreedatabase.com'
baseDir = './images'


DownloadFile = (uri, filename, callback)->
	request.head uri, (err, res, body)->
		if err || res.statusCode != 200
			console.log 'GOT ERROR', err
			return callback(new Error("ERR: #{err}"))
		console.log('content-type:', res.headers['content-type'])
		console.log('content-length:', res.headers['content-length'])
		request(uri).pipe(fs.createWriteStream(filename)).on('close', callback)


GetPhoto = ( dog, cb )->
	console.log 'Getting Photo', dog.id
	DownloadFile "#{baseUrl}#{dog.picurl}", "#{baseDir}/#{dog._id}.jpg", ( err )->
		if err
			console.log 'ERROR:', err
			return cb(err)
		dog.picdownloaded = true
		dog.save ( err )->
			if err
				console.log 'SAVE ERROR:', err
			cb(err)

Queue = async.queue( GetPhoto, 50 )


Queue.drain = ->
	console.log 'ALL DONE'


Schemas.Dog.find({ picdownloaded: false, picurl: {'$ne': '/images/nodog.png' } }).limit(10000).exec ( err, dogs )->
	console.log 'Dogs in DB:', dogs.length, dogs[0]

	# dogIDs = lodash.where( dogs, { picdownloaded: false } )
	# dogIDs = lodash.filter dogIDs, ( dog )->
		# return dog.picurl != '/images/nodog.png'

	console.log 'Downloading for:', dogs.length

	Queue.push(dogs)



