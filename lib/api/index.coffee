"use strict"

logger = require("../logger")


exports.awesomeThings = (req, res) ->
  res.json [
    "HTML5 Boilerplate"
    "AngularJS"
    "Karma"
    "Express"
  ]

exports.manufacturers = require("./manufacturers")
exports.products = require("./products")
exports.packages = require("./packages")
exports.releases = require("./releases")
exports.auth = require("./auth")
exports.account = require("./account")
exports.users = require("./users")

exports.utils = require("./utils")

###
Test utils:

curl -d "name=moto&logo_path=images/moto.png"   http://127.0.0.1:9000/api/manufacturers/
curl -v -X POST -H Accept:application/json -H Content-Type:application/json  -d '{"name":"moto","logo_path":"images"}' http://127.0.0.1:9000/api/manufacturers

###
