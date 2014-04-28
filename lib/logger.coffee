'use strict'

# Use this module for a customizable logging. - https://github.com/flatiron/winston
winston = require('winston')

if process.env.NODE_ENV is "development"
  logger = new winston.Logger
    transports: [
      new winston.transports.Console {level: "debug", colorize: true, timestamp: true}
      # TODO: we may need to save logs to some files or DB.
      # new winston.transports.File filename: 'somefile.log'
    ]
else
  logger = new winston.Logger
    transports: [
      new winston.transports.Console {level: "info", colorize: true, timestamp: true}
      # new winston.transports.File filename: 'somefile.log'
    ]


exports = module.exports = logger