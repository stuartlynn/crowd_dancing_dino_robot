express = require('express')
app     = express();
http    = require('http').Server(app)
io      = require('socket.io')(http)

app.use(express.static('public'))

#generate your own API Keys and put them in config.coffee

agg_interval = 100

@sockets  = []
@agg      = {x: 0, y: 0, z:0}
@total_measurements  = 0


send_data = (data)=>
  console.log "setind data", data
  io.emit('agg_data' , data)

io.on 'connection', (socket)=>
  console.log "client connected"
  @sockets.append
  socket.on "boogy_data", (data)=>
    @agg.x += data.x
    @agg.y += data.y
    @agg.z += data.z
    @total_measurements += 1.0

setInterval =>
  console.log "total measurements #{@total_measurements} #{@agg.x} #{@agg.y} #{@agg.z}"
  @ave = { x: (@agg.x / @total_measurements) , y: (@agg.y / @total_measurements), z: (@agg.z / @total_measurements)}

  send_data @ave
  @agg = {x: 0, y: 0, z:0}
  @total_measurements = 0.0
, agg_interval

port = 3344 # process.argv[2] || process.env.PORT || 3000
console.log "listening on #{port}"
http.listen(port);
