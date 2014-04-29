"use strict"

logger = require("../logger")


exports.awesomeThings = (req, res) ->
  res.json [
    "HTML5 Boilerplate"
    "AngularJS"
    "Karma"
    "Express"
  ]



exports.utils = require("./utils")
