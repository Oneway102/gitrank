"use strict"

http = require("http")
path = require("path")
express = require("express")
api = require("./lib/api")
routes = require("./lib/routes")

app = express()
# TODO: Using global variables is ugly; will pass in variable in the constructor.
global._app = app

# all environments
app.set "port", 9100 or process.env.PORT or 3000
app.engine 'html', require('ejs').renderFile
app.set 'view engine', 'html'
app.enable 'trust proxy'

# development only
if "development" is app.get("env")
  app.locals { appPath: path.join(__dirname, "app") }
  app.use express.static(path.join(__dirname, ".tmp"))
  app.use express.static(path.join(__dirname, "app"))
  app.use express.errorHandler()
  app.set 'views', path.join(__dirname, "app")
# production only
else
  app.locals { appPath: path.join(__dirname, "public") }
  app.use express.favicon(path.join(__dirname, "public/favicon.ico"))
  app.use express.static(path.join(__dirname, "public"))
  app.set 'views', path.join(__dirname, "public")

#app.use express.logger(stream: {write: (msg, encode) -> logger.info(msg)})
# Setup data.
app.use express.cookieParser() # needed for session cookie.
#app.use express.bodyParser()
app.use express.urlencoded()
app.use express.json()
app.use express.methodOverride()

# 


app.use app.router # api router


# All the APIs begin here.
app.get "/api/awesomeThings", api.awesomeThings

app.get "/api/rank", api.utils.getRank
app.get "/api/languages", api.utils.getLanguages


app.all "/api/*", (req, res) -> res.json 404, error: "API Not Found."

app.get '/views/*', routes.views
app.get '/*', (req, res) ->
  res.sendfile path.join(__dirname, "#{if 'development' is app.get('env') then 'app' else 'public'}/index.html")


http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port #{app.get('port')} in #{app.get('env')} mode."
