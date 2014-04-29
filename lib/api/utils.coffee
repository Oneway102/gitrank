'use strict'

#_ = require("underscore")
fs = require("fs")

compose = (item) ->
  JSON.parse(JSON.stringify(item))

exports = module.exports = 

  getRank: (req, res, next) ->
    lang = req.param("language")
    res.send fs.readFileSync "./test/language." + lang.toLowerCase()
  getLanguages: (req, res, next) ->
    result = [
      "JavaScript"
      "Python"
      "Java"
      "PHP"
#      "C++"
      "C"
      "CSS"
    ]
    res.json compose(result)