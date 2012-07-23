#!/usr/bin/env coffee

io = require 'socket.io-client'
SDL = require 'sdl'

#pentawallHD
socketio = io.connect 'http://bender.hq.c3d2.de:2350'

#pentawall
#socketio = io.connect 'http://ledwall.hq.c3d2.de:2338'

#g3d2
#socketio = io.connect 'http://bender.hq.c3d2.de:2339'

socketio.on 'disconnect' , =>
	console.log 'disconnect'

socketio.on 'connecting' , (transport) =>
	console.log 'connecting via:'+transport
	

socketio.on 'init' , (configuration) =>

	console.log 'connected to:'+configuration.name

	SDL.init SDL.INIT.VIDEO
	
	SDL.WM.setCaption configuration.name,configuration.name

	factor = 18

	if configuration.width > 30
		factor = 10

	screen = SDL.setVideoMode configuration.width*factor, configuration.height*factor, 32, SDL.SURFACE.HWSURFACE | SDL.SURFACE.DOUBLEBUF | SDL.SURFACE.HWACCEL

	SDL.events.on 'KEYDOWN' , (evt) =>
		if (evt.sym is 99 and evt.mod is 64) or ( evt.sym is 27 and evt.mod is 0 )
			process.exit 0

	socketio.on 'frame', (data) =>
		
		socketio.emit 'ack'

		for i in [0 .. configuration.height-1]
			for j in [0 .. configuration.width-1]

				if configuration.subpixelOrder is 'rrggbb'
					r = data.buf.charCodeAt (i*24+j)*3
					g = data.buf.charCodeAt (i*24+j)*3+1
					b = data.buf.charCodeAt (i*24+j)*3+2
					SDL.fillRect screen, [j*factor,i*factor,factor,factor ], SDL.mapRGB( screen.format,r,g,b )
		
				if configuration.subpixelOrder is 'g'
					g = data.buf.charCodeAt i * (configuration.width/2) + j
					g1 = Math.floor( (g & 0x0f)*0x10 )*1.06
					g2 = Math.floor(  g - (g & 0x0f) )*1.06
					SDL.fillRect screen, [j*2*factor,i*factor,factor,factor ], SDL.mapRGB( screen.format,0,g1,0 )
					SDL.fillRect screen, [(j*2+1)*factor,i*factor,factor,factor ], SDL.mapRGB( screen.format,0,g2,0 )

		SDL.flip screen

