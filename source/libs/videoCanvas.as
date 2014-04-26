package libs {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import flash.media.Video;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import flash.display.StageDisplayState;
	
	public class videoCanvas extends MovieClip {
		
		public var bufferTime:Number = 3;
		
		// Double-buffering values for fast playback
		public var loBufferTime:Number = 3;
		public var hiBufferTime:Number = 15;				
		
		public var streamServer:String = null;		
		
		private var width_:Number = 0;
		private var height_:Number = 0;
		private var file_:String = ''; //video file url
		private var type_:String = ''; //video file ext
		private var autoplay_ = false; //start play after load
		
		private var volume_:Number = 0.5;
		private var soundTF_:SoundTransform = new SoundTransform();
		
		//file meta data
		private var videoMetaWidth_ = 0;
   	 	private var videoMetaHeight_ = 0;
		public var videoMetaDuration = 0;
		
		private var durationDiff = 0;
		
		private var videoCreated = false;
		private var playing_:Boolean = false;
		private var paused_:Boolean = false;
		
		private var video:Video = new Video(); //main video object
		private var videoHolder:MovieClip = new MovieClip(); //video holder
		private var connect_nc:NetConnection = new NetConnection();
		public var stream_ns:NetStream;
		
		private var bg:Sprite = new Sprite(); //player bg
		//private var bgColor:Number = 0xFF000000; //player bg color
		private var fsbgColor:Number = 0xFF000000; //player bg color

		public function videoCanvas( width_, height_ ) {
			//set dimension
			this.width_ = width_;
			this.height_ = height_;
			
			this.addChild( this.bg ); //ad bg layer
			this.addChild( this.videoHolder );
			
		}
		
		//initialize player
		public function initPlayer() {
			if ( this.autoplay_ )
				this.Play();
		}
		
		//set the video/audio file 
		public function setFile( file ) {
			this.file_ = file;
			this.type_ = file.substr( file.lastIndexOf('.') + 1, file.length );			
			//this.initPlayer();			
		}
		
		//check if playing
		public function isPlaying():Boolean {
			return this.playing_;	
		}
		
		//pause file
		public function Pause() {
			this.playing_ = false;
			this.paused_ = true;
			this.stream_ns.pause();
		}
		
		//file end by playing
		public function Ended() {
			this.playing_ = false;
			this.paused_ = true;
			this.stream_ns.pause();
			/*
			this.stream_ns.seek(0);
			this.stream_ns.play(this.videoUrl);
			this.stream_ns.pause();
			*/
		}
		
		//replay
		public function Replay() {
			this.stream_ns.seek(0);
		}
		
		
		//play file		
		public var initStarted = false;
		public function Play() {						
			this.playing_ = true;
			this.paused_ = false;
			
			if ( !this.videoCreated ) {								
				
				this.videoCreated = true;
				
				var client:Object = new Object();								
				// Custom playback client						
				client.onBWDone   = function(e){};
				client.onMetaData = this.onMetaData_;
				client.onCuePoint = function(e){};

				this.connect_nc.client = client;					
				this.connect_nc.addEventListener( NetStatusEvent.NET_STATUS, this.onServerStatus, false, 0, true );								 
			
				trace( this.streamServer );
				this.connect_nc.connect( this.streamServer );				
				
			} else {
				
				this.stream_ns.resume();
				
			}
			
			if ( this.videoMetaDuration > 0 && Math.ceil( this.stream_ns.time ) >= Math.ceil( this.videoMetaDuration ) ) {
				this.Replay();
			}
			
			trace(this.stream_ns.time, this.videoMetaDuration);			
		
		}
				
		
		public function onServerStatus( event:NetStatusEvent ) {
			trace(event.info.code);
			switch(event.info.code) {
				case "NetConnection.Connect.Success":
					trace("Server Connected");
					
					this.stream_ns = new NetStream( this.connect_nc );					
					if ( !this.isStream() )
						this.stream_ns.bufferTime = this.loBufferTime;
					else
						this.stream_ns.bufferTime = 0;
					
					this.setVolume( this.volume_ );
					
					this.video = new Video();
					this.video.smoothing = true;
					this.video.deblocking = 1;
					this.video.width = this.width_;
					this.video.height = this.height_;
					
					if ( !this.videoHolder.contains( this.video ) )
						this.videoHolder.addChild( this.video );								
					
					this.video.attachNetStream( this.stream_ns );
					
					this.stream_ns.addEventListener( NetStatusEvent.NET_STATUS, this.netStatusHandler );
					this.stream_ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorEventHandler );
					
					var client:Object = new Object();
					client.onMetaData = onMetaData_;
					this.stream_ns.client = client;
										
					if ( this.streamServer ) {
						trace( this.type_+':'+this.file_ );
						this.stream_ns.play( this.type_+':'+this.file_ );	
						trace('stream');												
					} else {
						trace(this.file_);
						this.stream_ns.play( this.file_, -1 );	
						trace('not stream');						
					}
					break;
			}
		}
		
		//goto time
		public function playFrom( sec:Number ) {
			this.stream_ns.seek( sec );				
		}
		
		//resize player
		public function resize( width_, height_ ) {
			//update dimension
			this.width_ = width_;
			this.height_ = height_;
			
			//this.setBackgroundColor( this.bgColor );
			
			this.video.width = this.width_;
			this.video.height = this.height_;

			this.resizeVideo( this.videoMetaWidth_, this.videoMetaHeight_, this.width_, this.height_ ); // resize video

		}
		
		//resize video
		private function resizeVideo( wfrom, hfrom, wto, hto ) {
			var new_width = 0, 
				new_height = 0, 
				percent = 0,
				width_pro = 0,
				height_pro = 0;
			
			// fit in the frame if the video resolution is bigger than the frame
			if ( wfrom > hfrom ) {
				
				new_width = wto;
				percent = wto * 100 / wfrom;
				new_height = hfrom * percent / 100;
				
				if ( new_height > hto ) {
					height_pro = new_height;
					new_height = hto;
					percent = hto * 100 / height_pro;	
					new_width = new_width * percent / 100;
				}
				
			} else {
				
				new_height = hto;
				percent = hto * 100 / hfrom;
				new_width = hfrom * percent / 100;
				
				if ( new_width > wto ) {
					width_pro = new_width;
					new_width = wto;
					percent = wto * 100 / width_pro;
					new_height = new_height * percent / 100;
				}
				
			}		
			
			
			new_width = parseInt( new_width );
			new_height = parseInt( new_height );
			
			this.video.width = new_width;
			this.video.height = new_height;			
			
			this.videoHolder.x = ( this.width_ - new_width ) / 2;
			this.videoHolder.y = ( this.height_ - new_height ) / 2;
			
		}
		
		//on meta data
		private function onMetaData_(info:Object):void {
			this.videoMetaWidth_ = info.width;
   	 		this.videoMetaHeight_ = info.height;	
			this.videoMetaDuration = info.duration - this.durationDiff;			
			this.resizeVideo( this.videoMetaWidth_, this.videoMetaHeight_, this.width_, this.height_ ); // resize video
			//this.videoCreated = true; // set flag for video was created
			//trace('created');
			dispatchEvent( new Event('videoCreated') );
		}		
		
		//video error hadnler
		function asyncErrorEventHandler( event:AsyncErrorEvent ):void {
			// ignore
			//trace(event);
		}
		
		//stream net status handler
		public var firstNetstream = false;
		private function netStatusHandler( event:NetStatusEvent ):void {
			trace(event.info.code);
			if ( this.firstNetstream ) {				
				switch (event.info.code) {
					case "NetStream.Play.Start":
						dispatchEvent( new Event('start') );
						break;
					case "NetStream.Play.StreamNotFound":					
						dispatchEvent( new Event('streamNotFound') );					
						break;
					case "NetStream.Seek.InvalidTime":
						this.playFrom( this.stream_ns.time );					
						break;
					case "NetStream.Buffer.Empty":					
					case "NetStream.Seek.Notify":
					case "NetStream.Unpause.Notify":
						//trace('bufferEmpty');
						if ( !this.isStream() ) {
							this.stream_ns.bufferTime = this.loBufferTime;
						} else {
							if ( this.videoMetaDuration > 0 && this.stream_ns.time > this.videoMetaDuration - 1 ) {
								trace('playStop');
								this.Ended();
								dispatchEvent( new Event('playStop') );
							}
						}
						dispatchEvent( new Event('bufferEmpty') );						
						break;
					case "NetStream.Buffer.Full":
					case "NetStream.Buffer.Flush":												
						if ( !this.isStream() )
							this.stream_ns.bufferTime = this.hiBufferTime;
						dispatchEvent( new Event('bufferFull') );
						dispatchEvent( new Event('bufferFlush') );
						break;
					case "NetStream.Play.Stop":
						if ( !this.isStream() ) {
							if ( this.videoMetaDuration > 0 && this.stream_ns.time > this.videoMetaDuration - 1 ) {
								trace('playStop');
								this.Ended();
								dispatchEvent( new Event('playStop') );
							}
						}
						break;
				}
			} else {
				this.firstNetstream = true;
			}
			/*
			if(p_evt.info.code == "NetStream.FileStructureInvalid")
			{
				trace("The MP4's file structure is invalid.");
			}
			else if(p_evt.info.code == "NetStream.NoSupportedTrackFound")
			{
				trace("The MP4 doesn't contain any supported tracks");
			}
			*/
		}		
		
		//set auto play
		public function setAutoPlay( val:Boolean = true ) {
			this.autoplay_ = val;
			//this.initPlayer();
		}
		
		//set/update background color
		/*
		public function setBackgroundColor( color:Number ) {		
			this.bgColor = color;
			this.graphics.clear();
			try {
				if ( stage.displayState == StageDisplayState.FULL_SCREEN ) {
					this.graphics.beginFill( this.fsbgColor );
				} else {
					this.graphics.beginFill( this.bgColor );
				}
			} catch (errObject:Error) {
				this.graphics.beginFill( this.bgColor );
			}			
			this.graphics.drawRect( 0, 0, this.width_, this.height_ );
			this.graphics.endFill();
		}
		*/
		
		//set/update background color
		public function setFsBackgroundColor( color:Number ) {		
			this.fsbgColor = color;
		}
		
		public function setVolume( volume_:Number ) {
			this.volume_ = volume_;
			if ( this.stream_ns ) {
				if ( this.soundTF_.volume != this.volume_ ) 
					dispatchEvent( new Event('volumeChange') );
				this.soundTF_.volume = this.volume_;
				this.stream_ns.soundTransform = this.soundTF_;	
			}
		}
		
		public function getVolume() {
			return this.volume_;
		}
		
		public function getTime() {
			var ms_ = this.stream_ns.time - this.durationDiff;
			return ms_ > 0 ? ms_ : 0;						
		}		
		
		public function setBufferTime( bufferTime:Number ) {
			this.bufferTime = bufferTime;
			this.loBufferTime = bufferTime;
			this.hiBufferTime = bufferTime * 5;
		}
		
		public function setStreamServer( streamServer:String ) {
			this.streamServer = streamServer == '' ? null : streamServer; 
		}
		
		public function isStream() {
			return ( this.streamServer != null );
		}

	}
	
}
