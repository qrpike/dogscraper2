



# Requires
EventEmitter = require('events').EventEmitter
request = require('request')
lodash = require('lodash')
async = require('async')
fs = require('fs')
cheerio = require('cheerio')

mongoose = require('mongoose')
Schemas = require('./schemas/schemas.js')




# Connect to DB:
mongoose.connect('mongodb://localhost/pedigree')

baseUrl = 'https://www.pedigreedatabase.com/register.html?dogid='



class DetailGetter extends EventEmitter

	constructor: ( @dog, @callback, @data = '', @$ = '' )->
		@id = @dog.id
		@init()

	init: =>
		request "#{baseUrl}#{@id}", ( err, response, data )=>
			if !err && response.statusCode == 200
				@data = data
				return @parseData()
			console.log 'GOT ERROR:', err
			@callback( err )

	parseData: =>
		@$ = cheerio.load( @data )
		@extractDetails()

	inputValue: ( inputName )=>
		val = @$("[name='#{inputName}']").val()
		return val

	extractDetails: =>
		$ = @$
		console.log 'Extracting Details..'
		dog = @dog

		# dog.name = @inputValue('name_in')
		dog.entitlements = @inputValue('title_in')
		# dog.breed = @inputValue('dog_breed')
		# dog.sex = @inputValue('kyn_in')
		dog.regType = @inputValue('regtype_in')
		dog.regNumber = @inputValue('regnumber_in')
		dog.achievements = @inputValue('achievement_in')
		dog.ed = @inputValue('fhd_in')
		dog.hd = @inputValue('bhd_in')
		dog.tattoo = @inputValue('tattoo_in')
		dog.dna = @inputValue('dna_in')
		dog.microchip = @inputValue('microchip_in')
		dog.kkl = @inputValue('kkl_in')

		dog.gotdetails = true

		if dog.tattoo is undefined
			console.log 'PAGE ERROR'
			return callback(new Error('PAGE MISSING'))

		console.log 'SAVED:', dog

		dog.save ( err )=>
			if err
				console.log 'SAVE ERROR:', err
			@callback(err)
	


Queue = async.queue (dog,cb)->
	dg = new DetailGetter( dog, cb )
, 10


Queue.drain = ->
	console.log 'ALL DONE'


Schemas.Dog.find({ gotdetails: false }).limit(50000).exec ( err, dogs )->
	console.log 'Dogs in DB:', dogs.length

	dogIDs = lodash.where( dogs, { gotdetails: false } )

	console.log 'Downloading for:', dogIDs.length

	Queue.push(dogIDs)




