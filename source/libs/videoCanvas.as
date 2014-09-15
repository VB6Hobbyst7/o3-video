/*
O3 Video Player Video Canvas
libs.videoCanvas
Created by Zoltan Lengyel-Fischer (2014)
*/

package libs
{

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

	public class videoCanvas extends MovieClip
	{

		public var bufferTime:Number = 3;

		//Double-buffering values for fast playback
		public var loBufferTime:Number = 3;
		public var hiBufferTime:Number = 15;

		public var streamServer:String = null;

		private var width_:Number = 0;
		private var height_:Number = 0;
		private var file_:String = '';//video file url
		private var type_:String = '';//video file ext
		private var autoplay_ = false;//start play after load

		private var volume_:Number = 0.5;
		private var soundTF_:SoundTransform = new SoundTransform();

		//File meta data
		private var videoMetaWidth_ = 0;
		private var videoMetaHeight_ = 0;
		public var videoMetaDuration = 0;		

		private var videoCreated = false;
		private var playing_:Boolean = false;
		private var paused_:Boolean = false;

		private var video:Video = new Video();//main video object
		private var videoHolder:MovieClip = new MovieClip();//video holder
		private var connect_nc:NetConnection = new NetConnection();
		public var stream_ns:NetStream = null;

		private var bg:Sprite = new Sprite();//player bg
		//private var bgColor:Number = 0xFF000000;//player bg color
		private var fsbgColor:Number = 0xFF000000;//player bg color

		//Constructor
		public function videoCanvas( width_, height_ ) {
			//Set dimension
			this.width_ = width_;
			this.height_ = height_;

			this.addChild( this.bg );//Ad bg layer
			this.addChild( this.videoHolder );

		}

		//Initialize player
		public function initPlayer()
		{
			if (this.autoplay_)
			{
				this.Play();
			}
		}

		//Set the video/audio file 
		public function setFile( file )
		{
			this.file_ = file;
			this.type_ = file.substr(file.lastIndexOf('.') + 1,file.length);
			//this.initPlayer();
		}

		//Check if playing
		public function isPlaying():Boolean
		{
			return this.playing_;
		}

		//Pause file
		public function Pause()
		{
			this.playing_ = false;
			this.paused_ = true;
			try{
			  this.stream_ns.pause();
			} catch(e:Error){}				
		}

		//File end by playing
		public function Ended()
		{
			this.playing_ = false;
			this.paused_ = true;
			try{
			  this.stream_ns.pause();
			} catch(e:Error){}
			/*
			this.stream_ns.seek(0);
			this.stream_ns.play(this.videoUrl);
			this.stream_ns.pause();
			*/
		}

		//Replay
		public function Replay()
		{			
			try{
				this.stream_ns.seek(0);
			} catch(e:Error){}
		}


		//Play file
		public var initStarted = false;
		public function Play()
		{
			this.playing_ = true;
			this.paused_ = false;
						
			if ( !this.videoCreated ) {
				this.videoCreated = true;

				var client:Object = new Object();
				//Custom playback client
				client.onBWDone = function(e){};
				client.onMetaData = this.onMetaData_;
				client.onCuePoint = function(e){};

				this.connect_nc.client = client;
				this.connect_nc.addEventListener( NetStatusEvent.NET_STATUS, this.onServerStatus, false, 0, true );

				//trace( this.streamServer );
				this.connect_nc.connect( this.streamServer );
				
				//Reset stream
				try{
				  this.stream_ns.seek(0);
				} catch(e:Error){}

			} else {				
				try{
				  this.stream_ns.resume();
				} catch(e:Error){}
			}

			if (this.videoMetaDuration > 0 && this.stream_ns && Math.ceil(this.stream_ns.time) >= Math.ceil(this.videoMetaDuration) ) {
				this.Replay();
			}			

		}


		public function onServerStatus( event:NetStatusEvent )
		{
			//trace(event.info.code);
			switch (event.info.code)
			{
				case "NetConnection.Connect.Success" :	
				
					if ( this.stream_ns == null ) {
						this.stream_ns = new NetStream(this.connect_nc);
						if (! this.isStream()) {
							this.stream_ns.bufferTime = this.loBufferTime;
						} else {
							this.stream_ns.bufferTime = 0;
						}
						this.setVolume( this.volume_ );
	
						this.video = new Video();
						this.video.smoothing = true;
						this.video.deblocking = 1;
						this.video.width = this.width_;
						this.video.height = this.height_;
						this.video.opaqueBackground = null;
	
						if (! this.videoHolder.contains(this.video))
						{
							this.videoHolder.addChild( this.video );
						}
	
						this.video.attachNetStream( this.stream_ns );
	
						this.stream_ns.addEventListener( NetStatusEvent.NET_STATUS, this.netStatusHandler );
						this.stream_ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorEventHandler );
	
						var client:Object = new Object();
						client.onMetaData = onMetaData_;
						this.stream_ns.client = client;
	
						if ( this.streamServer ) {
							//trace( this.type_+':'+this.file_ );
							try {
								this.stream_ns.play( this.type_+':'+this.file_ );
							} catch (err:Error) {}
							//trace('stream');
						}
						else
						{
							//trace(this.file_);
							try {
								this.stream_ns.play( this.file_, -1 );
							} catch (err:Error) {}
							//trace('not stream');
						}
					}
					break;
			}
		}

		//Goto time
		public function playFrom( sec:Number ) {
			try {
				this.stream_ns.seek( sec );			
			} catch (err:Error) {}
		}
		
		//Goto time (percent)
		public function playFromPercent( percent:Number ) {
			try {
				
				var seek_ = Math.ceil(this.videoMetaDuration) * percent,
					playing_ = this.isPlaying();
				seek_ = seek_ >= this.videoMetaDuration ? this.videoMetaDuration - this.videoMetaDuration * 0.005 : seek_; 
				
				this.stream_ns.pause();
				this.stream_ns.seek( seek_ );								
				if ( playing_ )
					this.stream_ns.resume();				
			} catch (err:Error) {}
		}

		//Resize player
		public function resize( width_, height_ )
		{
			//Update dimension
			this.width_ = width_;
			this.height_ = height_;

			//this.setBackgroundColor( this.bgColor );

			this.video.width = this.width_;
			this.video.height = this.height_;

			//Resize video	
			this.resizeVideo( this.videoMetaWidth_, this.videoMetaHeight_, this.width_, this.height_ );
			
		}

		//Resize video
		private function resizeVideo( wfrom, hfrom, wto, hto )
		{
			var new_width = 0, 
			new_height = 0, 
			percent = 0,
			width_pro = 0,
			height_pro = 0;

			//Fit in the frame if the video resolution is bigger than the frame
			if (wfrom > hfrom)
			{

				new_width = wto;
				percent = wto * 100 / wfrom;
				new_height = hfrom * percent / 100;

				if (new_height > hto)
				{
					height_pro = new_height;
					new_height = hto;
					percent = hto * 100 / height_pro;
					new_width = new_width * percent / 100;
				}

			}
			else
			{

				new_height = hto;
				percent = hto * 100 / hfrom;
				new_width = hfrom * percent / 100;

				if (new_width > wto)
				{
					width_pro = new_width;
					new_width = wto;
					percent = wto * 100 / width_pro;
					new_height = new_height * percent / 100;
				}

			}


			new_width = parseInt(new_width);
			new_height = parseInt(new_height);

			this.video.width = new_width;
			this.video.height = new_height;

			this.videoHolder.x = ( this.width_ - new_width ) / 2;
			this.videoHolder.y = ( this.height_ - new_height ) / 2;

		}

		//On meta data load
		private var videoMetaLoaded_:Boolean = false;
		private function onMetaData_(info:Object):void
		{				
			this.videoMetaWidth_ = info.width;
			this.videoMetaHeight_ = info.height;
			this.videoMetaDuration = info.duration;
			//Resize video
			this.resizeVideo( this.videoMetaWidth_, this.videoMetaHeight_, this.width_, this.height_ );
			if ( !videoMetaLoaded_ ) {
				videoMetaLoaded_ = true;
				dispatchEvent( new Event('videoCreated') );
			}
		}

		//Video error hadnler
		function asyncErrorEventHandler( event:AsyncErrorEvent ):void
		{
			//Ignore
			trace(event);
		}

		//Stream net status handler
		public var firstNetstream = false;
		private function netStatusHandler( event:NetStatusEvent ):void
		{	
			//Netstream event info before load
			trace(event.info.code);
			switch (event.info.code) {
				case "NetStream.Play.StreamNotFound" :		
					dispatchEvent( new Event('streamNotFound') );
					break;
			}
		
			//Netstream event info after load
			if (this.firstNetstream)
			{
				switch (event.info.code)
				{
					case "NetStream.Play.Start" :
						dispatchEvent( new Event('start') );
						break;					
					case "NetStream.Seek.InvalidTime" :
						try {
							this.playFrom( this.stream_ns.time );
						} catch (err:Error) {}
						break;
					case "NetStream.Buffer.Empty" :
					case "NetStream.Seek.Notify" :
					case "NetStream.Unpause.Notify" :
						//trace('bufferEmpty');
						if ( this.stream_ns && !this.isStream() )	{
							this.stream_ns.bufferTime = this.loBufferTime;
						}
						else
						{	
							if ( this.videoMetaDuration > 0 && this.stream_ns && Math.ceil(this.stream_ns.time) >= Math.ceil(this.videoMetaDuration) ) {
								//trace('playStop');
								this.Ended();
								dispatchEvent( new Event('playStop') );
							}
						}
						dispatchEvent( new Event('bufferEmpty') );
						break;
					case "NetStream.Buffer.Full" :
					case "NetStream.Buffer.Flush" :
						if ( this.stream_ns && !this.isStream() ) {
							this.stream_ns.bufferTime = this.hiBufferTime;
						}
						dispatchEvent( new Event('bufferFull') );
						dispatchEvent( new Event('bufferFlush') );
						break;
					case "NetStream.Play.Stop" :
						if (! this.isStream())
						{
							if (this.videoMetaDuration > 0 && this.stream_ns && Math.ceil(this.stream_ns.time) >= Math.ceil(this.videoMetaDuration) ) {
								//trace('playStop');
								this.Ended();
								dispatchEvent( new Event('playStop') );
							}
						}
						break;
				}
			}
			else
			{
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

		//Set auto play
		public function setAutoPlay( val:Boolean = true )
		{
			this.autoplay_ = val;
			//this.initPlayer();
		}

		//Set/update background color
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

		//Set/update background color
		public function setFsBackgroundColor( color:Number )
		{
			this.fsbgColor = color;
		}

		public function setVolume( volume_:Number, trigger_event = true )
		{
			this.volume_ = volume_;
			this.mute = this.volume_ == 0 ? true:false;
			
			if (this.soundTF_.volume != this.volume_ && trigger_event) {
				dispatchEvent( new Event('volumeChange') );
			}
			this.soundTF_.volume = this.volume_;
			try {
				this.stream_ns.soundTransform = this.soundTF_;
			} catch(e:Error){}			
		}

		private var old_volume_:Number = 0;
		public var mute:Boolean = false;
		public function setMute( value:Boolean = true, trigger_event = true )
		{
			this.mute = value;
			if (this.mute) 
				this.old_volume_ = this.volume_;			
			setVolume( this.mute ? 0 : ( this.old_volume_ == 0 ? 1 : this.old_volume_ ), trigger_event );
		}

		public function getVolume()
		{
			return this.volume_;
		}

		public function getDuration() {
			if ( this.videoCreated )
				return this.videoMetaDuration;
			return false;
		}
		
		public function getBufferLoaded() {			
			return this.stream_ns && this.stream_ns.bytesTotal > 0 ? this.stream_ns.bytesLoaded / this.stream_ns.bytesTotal : 0;
		}
		
		public function getTime()
		{
			//trace(this.stream_ns.time);			
			return this.stream_ns && this.stream_ns.time > 0 ? this.stream_ns.time : 0;
		}

		public function setBufferTime( bufferTime:Number )
		{
			this.bufferTime = bufferTime;
			this.loBufferTime = bufferTime;
			this.hiBufferTime = bufferTime * 5;
		}

		public function setStreamServer( streamServer:String )
		{
			this.streamServer = streamServer == '' ? null : streamServer;
		}

		public function isStream()
		{
			return ( this.streamServer != null );
		}

	}

}