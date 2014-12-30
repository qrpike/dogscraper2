


# Requires
EventEmitter = require('events').EventEmitter
request = require('request')
lodash = require('lodash')
async = require('async')
mongoose = require('mongoose')
Schemas = require('./schemas/schemas.js')




# Connect to DB:
mongoose.connect('mongodb://localhost/pedigree')

# Base URL:
baseUrl = 'https://www.pedigreedatabase.com/jdata.doginfo_new?generations=5&dogid='


hasScanned = []


class GenerationParser extends EventEmitter

	constructor: ( @id, @callback, @data = [] )->
		@init()

	init: =>
		console.log 'Getting URL:', "#{baseUrl}#{@id}"
		request "#{baseUrl}#{@id}", ( err, response, data )=>
			if !err && response.statusCode == 200
				@data = JSON.parse( data )
				return @parseData()
			console.log 'GOT ERROR:', err
			@callback( err )

	parseData: =>
		async.map @data, @saveDog, ( err, results )=>
			@callback( err, results )

	genDogData: ( dog )=>
		nd =
			name: dog.NAME
			title: dog.TITLE
			dob: dog.DOB
			id: dog.ID
			breed: dog.BREED
			sex: dog.SEX
			father: dog.FATHER
			mother: dog.MOTHER
			link: dog.LINKURL
			picurl: dog.PICTURE
			dogid: dog.DOGID
		return nd

	saveDog: ( dog, cb )=>
		AlreadyScanned dog.ID, ( hasScanned )=>
			if hasScanned
				return cb(null)
			console.log 'Saving Dog:', dog.ID
			dogData = @genDogData( dog )
			# hasScanned.push( dogData.id )
			nd = new Schemas.Dog( dogData )
			nd.save ( err )=>
				if err
					console.log 'ERROR:', err
					return cb?( err )
				Queue.unshift( nd.mother )
				Queue.unshift( nd.father )
				cb?( err, nd )



AlreadyScanned = ( id, cb )->
	Schemas.Dog.findOne({ id: id }).exec ( err, dog )=>
		if (err)
			console.log 'DB ERR:', err
			return throw err
		# console.log 'DOG:', dog
		if dog
			return cb( true )
		cb( false )


Queue = async.queue ( id, cb )->
	AlreadyScanned id, ( hasScanned )=>
		if hasScanned
			console.log 'Already Scanned:', id
			return cb(null)
		v = new GenerationParser( id, cb )
, 30


Queue.drain = ->
	console.log 'ALL DONE', hasScanned.length


toScan = [600000..550000]
Queue.push(toScan)









