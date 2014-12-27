
var mongoose = require('mongoose');
var Schema = mongoose.Schema;



var DogSchema = new Schema({

	id: {
		type: Number,
		unique: true,
		index: true,
		required: true
	},

	dogid: Number,
	name:  {
		type: String,
		required: true
	},
	breed: String,
	sex: String,
	title: String,
	dob: String,
	link: String,
	picurl: String,

	mother: Number,
	father:   Number,

	entitlements: String,
	regType: String,
	regNumber: String,
	achievements: String,
	tattoo: String,
	dna: String,
	microchip: String,
	kkl: Number,
	ed: String,
	hd: String,

	picdownloaded: {
		type: Boolean,
		default: false
	},

	gotdetails: {
		type: Boolean,
		default: false
	},

	created: {
		type: Date,
		default: Date.now
	}

});


module.exports = {
	Dog: mongoose.model('Dog', DogSchema)
};