class accel
  ready: false


  start:=>
    # window.addEventListener "compassneedscalibration", (event) =>
    #    alert('Your compass needs calibrating! Wave your device in a figure-eight motion');
    #    event.preventDefault();
    #    @ready = true
    # , false

    console.log("starting accel senseing")

    window.addEventListener 'devicemotion', (data)=>
      @processEvent(data)
    , false


  processEvent:(data)=>
    alpha = data.alpha
    beta  = data.beta
    gamma = data.gamma

    ra  = alpha
    dec = gamma
    data =  {x: data.acceleration.x, y: data.acceleration.y,  z: data.acceleration.z}

    for f in @callbacks
      f(data)

  onMove:(func)=>
    @callbacks ||= []
    @callbacks.push func

class reporter
  ready: false

  start:=>
    @socket = io()
    @ad_callbacks = []
    @socket.on "agg_data",(ad)=>
      console.log "agg data ", ad
      for callback in @ad_callbacks
        callback(ad)


  report_data:(data)=>
    @socket.emit("boogy_data",data )

  add_agg_callback:(cb)=>
    @ad_callbacks.push cb

class barViz
  start:(element)=>
    @element = element
    $(element).append("<div class='slider'></div>")

  update:(data)=>
    d = data + 50
    console.log $("#{@element} .slider")
    $("#{@element} .slider").css("left", "#{d}%")


a = new accel()
r = new reporter()
r.start()
a.start()


r.add_agg_callback (data)->
  window.xaggViz.update(data.x)
  window.yaggViz.update(data.y)
  window.zaggViz.update(data.z)

$(document).ready ->
  window.xViz =  new barViz()
  window.yViz =  new barViz()
  window.zViz =  new barViz()

  window.xaggViz =  new barViz()
  window.yaggViz =  new barViz()
  window.zaggViz =  new barViz()

  window.xViz.start("#xViz")
  window.yViz.start("#yViz")
  window.zViz.start("#zViz")

  window.xaggViz.start("#xaggViz")
  window.yaggViz.start("#yaggViz")
  window.zaggViz.start("#zaggViz")

  a.onMove r.report_data

  a.onMove (data)->

    window.xViz.update(data.x)
    window.yViz.update(data.y)
    window.zViz.update(data.z)
