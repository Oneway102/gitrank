'use strict'

require("http").globalAgent.maxSockets = 10000

exports = module.exports =
  mysql_url: process.env.MYSQL_URL or "mysql://b052:123456@localhost/sus_test"
  #mysql_url: process.env.MYSQL_URL or "mysql://test:12345@192.168.7.233/remote_task"
  #redis_url: process.env.REDIS_URL or "redis://localhost:6379/0"
  redis_url: process.env.REDIS_URL or "redis://192.168.7.233:6379/0"
  project_path: "/home/b052/temp/"
