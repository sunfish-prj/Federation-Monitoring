/**
 * This file is part of SUNFISH FRM.
 *
 * SUNFISH FRM is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SUNFISH FRM is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

//Author: Md Sadek Ferdous

var express = require('express');
var https = require('https');
var http = require('http');
var fs = require('fs');
var url = require( "url" );
var queryString = require( "querystring" );
var sleep = require('sleep');
var pveAPI = require("./pveAPI");
var agentAPI = require("./agentAPI");

var bodyParser = require('body-parser');


var app = express();

app.use(bodyParser.json());


var crypto = require('crypto'),
  key = new Buffer('eeng4ge0woobohgooqu4ieriwohgoo6C'); 

var Web3 = require('web3');
var web3 = new Web3();
var querystring = require('querystring');

var options = {
  key: fs.readFileSync('key1.pem'),
  cert: fs.readFileSync('cert1.pem')
};

app.use(bodyParser.urlencoded({ extended: true }));



/**
 * endpoints involving state APIs 
 **/

app.get('/frm/pve', function(req, res) {
   pveAPI.read(req,res); 
});

app.post('/frm/pve', function(req, res) {
   pveAPI.read(req,res); 
});

/**
 * endpoints involving Alert APIs 
 **/

app.get('/frm/agent', function(req, res) {
  agentAPI.store(req,res);
});

app.post('/frm/agent', function(req, res) {
  agentAPI.store(req,res);
});



// Create an HTTPS service identical to the HTTP service.
https.createServer(options, app).listen(8077);
console.log('Server started!');
