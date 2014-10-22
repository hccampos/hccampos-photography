require('coffee-script')
path = require('path')
http = require('http')
connect = require('connect')
serveStatic = require('serve-static')
compression = require('compression')
modRewrite = require('connect-modrewrite')

servePath = path.resolve(__dirname + '/../../build')

app = connect()
	.use(compression())
	.use(modRewrite([
		'^/albums(.)*$ /index.html'
	]))
	.use(serveStatic(servePath, {'index': ['index.html']}))

server = http.createServer(app)
port = Number(process.env.PORT ? 5000)
server.listen port, ->
	console.log("Listening on " + port)