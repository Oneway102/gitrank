'use strict'

_ = require("underscore")
fs = require("fs")

compose = (item) ->
  JSON.parse(JSON.stringify(item))

exports = module.exports = 
  getStorageServer: (req, res, next) ->
    # TODO: Need admin permission.
    res.json _.map req.data.storage_server.server, (server) ->
      delete server.auth
      compose server

  getFilePath: (file) ->
    return

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