/*
O3 Video Player Control 
libs.controlBar
Created by Zoltan Lengyel-Fischer (2014)
*/

package libs {

	import libs.Helvetica;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import fl.transitions.Tween;
 	import fl.transitions.easing.*;
 	import fl.transitions.TweenEvent;	
 	import flash.filters.DropShadowFilter;
	
	public class controlBar extends MovieClip {
		
		public var width_:Number = 0;
		public var height_:Number = 0;
		
		//Bar bg color
		private var bgColor:Number = 0x3c3c3c;
		private var fillColor:Number = 0xfbfbfb;
		private var toolBgColor:Number = 0x0b0b0b;
		private var toolFillBgColor:Number = 0xcfcfcf;		
		private var toolBorderColor:Number = 0x575757;
		private var toolBufferBgColor:Number = 0x434343;		
		private var toolBufferBorderColor:Number = 0x777777;				
				
		//Left/right padding
		private var padding:Number = 10;
				
		//Main bar
		private var mainHolder:MovieClip = new MovieClip();
		
		//Stop/play button
		private var playBtn:MovieClip = new MovieClip();
		private var playBtnWidth:Number = 18;
		private var playBtnHeight:Number = 18;		
		private var pauseBtn:MovieClip = new MovieClip();
		private var pauseBtnWidth:Number = 18;
		private var pauseBtnHeight:Number = 18;
		
		//Fullscreen button
		private var fullscreenBtn:MovieClip = new MovieClip();
		private var fullscreenBtnWidth:Number = 18;
		private var fullscreenBtnHeight:Number = 18;
		private var fullscreen:Boolean = false;
		
		//Seek control
		private var seekControl:MovieClip = new MovieClip();
		private var seekControlHeight:Number = 8;
		private var seekControlWidth:Number = 70;
		private var seek:Number = 0; //current percent	
		private var seekFullControl:MovieClip = new MovieClip();
		private var seekFullControlMask:MovieClip = new MovieClip();
		
		//Buffer control		
		private var bufferControl:MovieClip = new MovieClip();
		private var buffer:Number = 0; //buffer percent
		private var bufferControlMask:MovieClip = new MovieClip();
		
		//Seek nub
		private var seekNub:MovieClip = new MovieClip();
		private var seekNubWidth:Number = 20;
		private var seekNubHeight:Number = 12;
		private var seekNubX:Number = 0;
		
		//Volume control
		private var volumeControl:MovieClip = new MovieClip();
		private var volumeControlHeight:Number = 8;
		private var volumeControlWidth:Number = 70;		
		private var volumeControlMaxWidth:Number = 70;		
		private var volume:Number = 0;
		
		//Volume nub
		private var volumeNub:MovieClip = new MovieClip();
		private var volumeNubRadius:Number = 6.2;
		private var volumeNubX:Number = 0;
		
		//Volume button
		private var volumeBtn:MovieClip = new MovieClip();
		private var volumeBtnWidth:Number = 22;
		private var volumeBtnHeight:Number = 18;
		
		//Timer display
		private var timerText:TextField = new TextField();
		private var timerTextHeight:Number = 18;		
		private var time:Number = 0;
		
		//Playing status
		private var is_playing = false;
		
		//Fade in/out effect
		private var fadeInEffect:Object = null;
		private var fadeOutEffect:Object = null;
		
		//Fade flag, true if out, false if in
		private var is_faded = false;
		
		//Disable flag, true if disabled, false if not
		private var is_disabled = false;
	
		//Constructor
		public function controlBar( width_, height_ ) {
																				
			//Create main holder
			this.addChild(mainHolder);
			
			//Create buttons
			this.mainHolder.addChild(this.playBtn);
			this.mainHolder.addChild(this.pauseBtn);
			this.mainHolder.addChild(this.volumeBtn);
			this.pauseBtn.visible = !this.is_playing;			
			this.volumeBtn.buttonMode = this.playBtn.buttonMode = this.pauseBtn.buttonMode = true;
			this.volumeBtn.useHandCursor = this.playBtn.useHandCursor = this.pauseBtn.useHandCursor = false;
			this.playBtn.addEventListener( MouseEvent.CLICK, function() { if ( !is_disabled ) dispatchEvent( new Event('play') ); } );
			this.pauseBtn.addEventListener( MouseEvent.CLICK, function() { if ( !is_disabled ) dispatchEvent( new Event('pause') ); } );
			this.volumeBtn.addEventListener( MouseEvent.CLICK, function() { if ( !is_disabled ) dispatchEvent( new Event('mute') ); } );

			//Fullscreen buttons
			this.mainHolder.addChild(this.fullscreenBtn);
			this.fullscreenBtn.buttonMode = true;
			this.fullscreenBtn.useHandCursor = false;
			this.fullscreenBtn.addEventListener( MouseEvent.CLICK, function() { if ( !is_disabled ) dispatchEvent( new Event('fullscreen') ); } );
			
			//Timers
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Helvetica";
			textFormat.color = this.fillColor;
			textFormat.size = this.timerTextHeight * 0.8;
			
			this.timerText.height = this.timerTextHeight;
			this.timerText.text = '00:00:00';
			this.timerText.autoSize = TextFieldAutoSize.RIGHT;
			this.timerText.antiAliasType = AntiAliasType.ADVANCED;
			this.timerText.embedFonts = true;
			this.timerText.defaultTextFormat = textFormat;
			this.mainHolder.addChild(this.timerText); 
			
			//Colume control
			this.mainHolder.addChild(this.volumeControl);
			this.volumeControl.addEventListener( MouseEvent.MOUSE_DOWN, this.volumeControlMouseDown );
			//this.volumeControl.addEventListener( MouseEvent.CLICK, this.volumeControlMouseClick );
			//this.volumeControl.addEventListener( MouseEvent.MOUSE_MOVE, this.volumeControlMouseMove );
			
			this.volumeControl.addChild(this.volumeNub);
			this.volumeNub.graphics.beginFill( this.fillColor );
			this.volumeNub.graphics.drawCircle( 0, 0, this.volumeNubRadius );
			this.volumeNub.graphics.endFill();
			var shadowFilter = new DropShadowFilter( 1.0, 180, 0x000000, 1.0, 4.0,  4.0, 0.3, 1, false, false, false );
			var volumeNubFilter = new Array(); volumeNubFilter.push( shadowFilter );
			this.volumeNub.filters = volumeNubFilter;
			
			//Seek control
			this.mainHolder.addChild(this.seekControl);
			this.seekControl.addEventListener( MouseEvent.MOUSE_DOWN, this.seekControlMouseDown );
			//this.seekControl.addEventListener( MouseEvent.MOUSE_UP, this.seekControlMouseUp );
			//this.seekControl.addEventListener( MouseEvent.MOUSE_MOVE, this.seekControlMouseMove );
			
			//Buffer
			this.seekControl.addChild(this.bufferControl);
			this.bufferControl.addChild(this.bufferControlMask);
			this.bufferControl.mask = this.bufferControlMask;			
			//Filled
			this.seekControl.addChild(this.seekFullControl);
			this.seekFullControl.addChild(this.seekFullControlMask);
			this.seekFullControl.mask = this.seekFullControlMask;			
			//Nub
			this.seekControl.addChild(this.seekNub);
			this.seekNub.graphics.beginFill( this.fillColor );
			this.seekNub.graphics.drawRoundRect( 0, 0, this.seekNubWidth, this.seekNubHeight, 12, 12 );			
			this.seekNub.graphics.endFill();
			var seekNubFilter = new Array(); seekNubFilter.push( shadowFilter );
			this.seekNub.filters = seekNubFilter;			
			
			//Set dimension
			this.resize( width_, height_ );
			
			this.drawPlayButton();
			this.drawPauseButton();
			this.drawFullscreenButton();
			this.drawSeekFullControl();
			this.drawVolumeControl();
			this.drawSeekControl();	
			this.drawBufferControl();
			
			//Clear timer
			this.setTimer( 0 );
			
		}
		
		//Set fullscreen flag
		public function setFullscreen( fullscreen ) {
			this.fullscreen = fullscreen;
		}
		
		//Set timer
		public function setTimer( time:Number = 0 ) {
			this.time = time;			
			var sec = 0, hour = 0, min = 0;
			hour = Math.floor( this.time / 3600 );
			min = Math.floor( this.time / 60 );
			sec = Math.floor( this.time % 60 );
			this.timerText.text = ( hour > 0 ? hour.toString()+':' : '' )+
							  ( min < 10 && hour > 0 ? '0'+min.toString() : min.toString() )+':'+
							  ( sec > 9 ? sec.toString() : '0'+sec.toString() );
		}		
		
		//Reposition/resize object
		public function resize( width:Number, height:Number ) {
			this.width_ = width;
			this.height_ = height;
			
			//Draw background 
			mainHolder.graphics.clear();
			mainHolder.graphics.beginFill(this.bgColor);
			mainHolder.graphics.drawRoundRect(0,0,this.width_,this.height_,10,10);
			mainHolder.graphics.endFill();
			
			pauseBtn.y = playBtn.y = ( this.height_ - this.playBtnHeight ) / 2;
			pauseBtn.x = playBtn.x = this.padding;
			
			fullscreenBtn.y =( this.height_ - this.fullscreenBtnHeight ) / 2;
			fullscreenBtn.x = this.width_ - ( this.padding + this.fullscreenBtnHeight );
			
			//Sum the totla space needed not size changing controls
			var widthUsed = this.padding * 2 +
							this.fullscreenBtnWidth + 
							this.volumeBtnWidth + this.padding +
							this.timerText.width + this.padding +
							this.playBtnWidth + this.padding;
			
			//Sum the total space remains for size changing tools
			var widthRem = this.width_ - ( widthUsed + this.padding * 2 );						
			
			//Fit elements on different player size
			if ( this.width_ < 220 ) {
				seekControl.visible = false;
			} else if ( this.width_ < 300 ) {
				volumeControl.visible = false;
				seekControl.visible = true;
				this.volumeControlWidth = 0;
			} else if ( this.width_ < 400 ) {				
				this.volumeControlWidth = this.volumeControlMaxWidth / 2;
				volumeControl.visible = true;
				seekControl.visible = true;
			} else {
				this.volumeControlWidth = this.volumeControlMaxWidth;
				volumeControl.visible = true;
				seekControl.visible = true;
			}
			
			//Position volume control
			volumeControl.x = this.fullscreenBtn.x - this.padding - this.volumeControlWidth;
			volumeControl.y = ( this.height_ - this.volumeControlHeight ) / 2;
			this.drawVolumeControl();
			
			volumeNub.y = volumeNubRadius / 2 + 0.5;/*volumeControl.y + volumeNubRadius / 2 + 0.5*/;
						
			volumeBtn.y = ( this.height_ - this.volumeBtnHeight ) / 2;
			volumeBtn.x = volumeControl.x - ( this.volumeControlWidth == 0 ? 0 : this.padding ) - this.volumeBtnWidth;
			
			//Position timer
			timerText.x = this.volumeBtn.x - this.padding - this.timerText.width;
			timerText.y = ( this.height_ - this.timerText.height ) / 2;			
			
			//Buffer & seek update
			this.seekControl.x = playBtn.x + this.playBtnWidth + this.padding;
			this.seekControl.y = ( this.height_ - this.seekControlHeight ) / 2;										
			this.bufferControl.x = this.bufferControl.y = 0;
			this.seekControlWidth = timerText.x - this.seekControl.x - this.padding;
			this.drawSeekControl();
			this.drawSeekFullControl();
			this.drawBufferControl();
			
			seekNub.y = ( this.seekControlHeight - seekNubHeight ) / 2;
			
			if ( this.is_disabled ) {
				this.seekNub.visible = false;
				this.volumeNub.visible = false;
			} else {
				this.seekNub.visible = true;
				this.volumeNub.visible = true;
			}
			
		}
		
		//Draw play button
		function drawPlayButton() {			
			
			this.playBtn.graphics.clear();
			
			this.playBtn.graphics.beginFill( this.bgColor );			
			this.playBtn.graphics.drawRect( 0, 0, playBtnWidth, playBtnHeight );			
			this.playBtn.graphics.endFill();
			
			this.playBtn.graphics.beginFill( this.fillColor );			
			this.playBtn.graphics.moveTo(0, 0); 
			this.playBtn.graphics.lineTo(playBtnWidth, playBtnHeight / 2); 
			this.playBtn.graphics.lineTo(0, playBtnHeight); 
			this.playBtn.graphics.lineTo(0, 0);
			this.playBtn.graphics.endFill();
		}
		
		//Draw pause button
		function drawPauseButton() {
			this.pauseBtn.graphics.clear();
			
			this.pauseBtn.graphics.beginFill( this.bgColor );			
			this.pauseBtn.graphics.drawRect( 0, 0, pauseBtnWidth, pauseBtnHeight );			
			this.pauseBtn.graphics.endFill();
			
			this.pauseBtn.graphics.beginFill( this.fillColor );		
			
			this.pauseBtn.graphics.drawRoundRect( 0, 0, pauseBtnWidth / 2.5, pauseBtnHeight, 3, 3 );
			this.pauseBtn.graphics.drawRoundRect( pauseBtnWidth - pauseBtnWidth / 2.5, 0, pauseBtnWidth / 2.5, pauseBtnHeight, 3, 3 );
						
			this.pauseBtn.graphics.endFill();
		}
		
		//Draw fullscreen button
		function drawFullscreenButton() {
			this.fullscreenBtn.graphics.clear();
			
			this.fullscreenBtn.graphics.beginFill( this.fillColor );	
			this.fullscreenBtn.graphics.drawRoundRect( 0, 0, fullscreenBtnWidth, fullscreenBtnHeight, 3, 3 );
			this.fullscreenBtn.graphics.endFill();
			
			var w_ = fullscreenBtnWidth*0.27,
				h_ = fullscreenBtnHeight*0.27,
				l_ = fullscreenBtnWidth*0.15,
				t_ = fullscreenBtnHeight*0.15;
			this.fullscreenBtn.graphics.beginFill( this.bgColor );			
			this.fullscreenBtn.graphics.moveTo( l_, t_ ); 
			this.fullscreenBtn.graphics.lineTo( l_ + w_, t_ ); 
			this.fullscreenBtn.graphics.lineTo( l_, t_ + h_ ); 
			this.fullscreenBtn.graphics.lineTo( l_ , t_ );
			
			l_ = fullscreenBtnWidth - l_;
			t_ = fullscreenBtnHeight - t_;
			this.fullscreenBtn.graphics.beginFill( this.bgColor );			
			this.fullscreenBtn.graphics.moveTo( l_, t_ ); 
			this.fullscreenBtn.graphics.lineTo( l_, t_ - h_ ); 
			this.fullscreenBtn.graphics.lineTo( l_ - w_, t_ ); 
			this.fullscreenBtn.graphics.lineTo( l_, t_ ); 
			this.fullscreenBtn.graphics.endFill();
		}
		
		public function drawSeekFullControl() {
			
			this.seekFullControl.graphics.clear();
			
			this.seekFullControl.graphics.beginFill( this.toolFillBgColor );
			this.seekFullControl.graphics.lineStyle( 1, this.toolFillBgColor, 1, true );
			this.seekFullControl.graphics.drawRoundRect( 0, 0, this.seekControlWidth, this.seekControlHeight-1, 7, 7  );
			this.seekFullControl.graphics.endFill();
			
			this.seekFullControlMask.graphics.clear();
			
			this.seekFullControlMask.graphics.beginFill( 0x000000 );			
			this.seekFullControlMask.graphics.drawRect( 0, 0, this.seekControlWidth * this.seek, this.height_ );
			this.seekFullControlMask.graphics.endFill();
			
			var x = ( this.seekControlWidth - this.seekNubWidth + 2 ) * this.seek - 1;
			this.seekNub.x = x;
			
		}
		
		public function drawSeekControl() {
						
			this.seekControl.graphics.clear();
			
			this.seekControl.graphics.beginFill( this.bgColor );
			this.seekControl.graphics.drawRect( -this.padding / 2, -seekControlHeight, this.seekControlWidth + this.padding, this.seekControlHeight*3 );
			this.seekControl.graphics.endFill();
			
			this.seekControl.graphics.beginFill( this.toolBgColor );
			this.seekControl.graphics.lineStyle( 1, this.toolBorderColor, 1, true );
			this.seekControl.graphics.drawRoundRect( 0, 0, this.seekControlWidth, this.seekControlHeight-1, 7, 7  );
			this.seekControl.graphics.endFill();
			
		}
		
		public function drawBufferControl() {
			
			this.bufferControl.graphics.clear();
			this.bufferControl.graphics.beginFill( this.toolBufferBgColor );
			this.bufferControl.graphics.lineStyle( 1, this.toolBufferBorderColor, 1, true );
			this.bufferControl.graphics.drawRoundRect( 0, 0, this.seekControlWidth, this.seekControlHeight-1, 7, 7  );
			this.bufferControl.graphics.endFill();
			
			this.bufferControlMask.graphics.clear();
			
			this.bufferControlMask.graphics.beginFill( 0x000000 );			
			this.bufferControlMask.graphics.drawRect( 0, 0, this.seekControlWidth * this.buffer, this.height_ );
			this.bufferControlMask.graphics.endFill();
		
		}
		
		function drawVolumeControl() {
			
			this.volumeControl.graphics.clear();
			
			this.volumeControl.graphics.beginFill( this.bgColor );
			this.volumeControl.graphics.drawRect( -this.padding / 2, -volumeControlHeight, this.volumeControlWidth + this.padding, this.volumeControlHeight*3 );
			this.volumeControl.graphics.endFill();
			
			this.volumeControl.graphics.beginFill( this.toolBgColor );
			this.volumeControl.graphics.lineStyle( 1, this.toolBorderColor, 1, true );
			this.volumeControl.graphics.drawRoundRect( 0, 0, this.volumeControlWidth, this.volumeControlHeight-1, 7, 7  );
			this.volumeControl.graphics.endFill();
			
			if ( !this.is_disabled ) {
				this.volumeControl.graphics.beginFill( this.toolFillBgColor );
				this.volumeControl.graphics.lineStyle( 1, this.toolFillBgColor, 1, true );
				this.volumeControl.graphics.drawRoundRect( 0, 0, this.volumeControlWidth * this.volume, this.volumeControlHeight-1, 7, 7  );
				this.volumeControl.graphics.endFill();
			}
			
			var x = ( this.volumeControlWidth - 2 * this.volumeNubRadius + 2 ) * this.volume + this.volumeNubRadius - 1;
			this.volumeNub.x = x;
						
			//Draw volume button
			this.volumeBtn.graphics.clear();
						
			this.volumeBtn.graphics.beginFill( this.bgColor );
			this.volumeBtn.graphics.drawRect( 0, 0, volumeBtnWidth, volumeBtnHeight  );
			this.volumeBtn.graphics.endFill();
			
			this.volumeBtn.graphics.beginFill( this.fillColor );
			this.volumeBtn.graphics.drawRect( 0, ( this.volumeBtnHeight - 6 ) / 2, 4, 6  );
			this.volumeBtn.graphics.moveTo( 4, ( this.volumeBtnHeight - 6 ) / 2 );			
			this.volumeBtn.graphics.lineTo( 10, 0 );
			this.volumeBtn.graphics.lineTo( 10, this.volumeBtnHeight );
			this.volumeBtn.graphics.lineTo( 4, ( this.volumeBtnHeight - 6 ) / 2 + 6 );
			this.volumeBtn.graphics.endFill();
			
			this.volumeBtn.graphics.lineStyle( 2, this.fillColor, 1, true );
			if ( this.volume > 0 ) {
				this.volumeBtn.graphics.moveTo( 13, 6 );
				this.volumeBtn.graphics.curveTo( 16, this.volumeBtnHeight - 9, 13, this.volumeBtnHeight - 6 );
			}
			
			if ( this.volume > 0.3 ) {
				this.volumeBtn.graphics.moveTo( 16, 4 );
				this.volumeBtn.graphics.curveTo( 21, this.volumeBtnHeight - 9, 16, this.volumeBtnHeight - 4 );			
			}
			
			if ( this.volume > 0.6 ) {
				this.volumeBtn.graphics.moveTo( 19, 2 );
				this.volumeBtn.graphics.curveTo( 25, this.volumeBtnHeight - 9, 19, this.volumeBtnHeight - 2 );
			}
			
			if ( this.volume == 0 ) {
				this.volumeBtn.graphics.lineStyle( 3, this.bgColor, 1, true );
				this.volumeBtn.graphics.moveTo( 2, this.volumeBtnHeight - 1 );
				this.volumeBtn.graphics.lineTo( 15, 3 );
								
				this.volumeBtn.graphics.moveTo( 2, this.volumeBtnHeight - 4 );
				this.volumeBtn.graphics.lineTo( 15, 0 );
								
				this.volumeBtn.graphics.lineStyle( 2, this.fillColor, 1, true );
				this.volumeBtn.graphics.moveTo( 2, this.volumeBtnHeight - 2 );
				this.volumeBtn.graphics.lineTo( 15, 2 );
			}
			
		}
		
		//Show play
		public function playing() {
			this.is_playing = true;
			this.playBtn.visible = !this.is_playing;
			this.pauseBtn.visible = this.is_playing;
		}
		
		//Show pause
		public function paused() {
			this.is_playing = false;
			this.playBtn.visible = !this.is_playing;
			this.pauseBtn.visible = this.is_playing;
		}
		
		//Fade controls in
		public function fadeIn() {
			if ( is_faded ) {				
				this.is_faded = false;
				if ( this.fadeInEffect != null )
					this.fadeInEffect.stop();
				if ( this.fadeOutEffect != null )
						this.fadeOutEffect.stop();
				this.fadeInEffect = new Tween( this, "alpha", Regular.easeIn, this.alpha, 1, 0.05, true);
				this.fadeInEffect.start();
			}
		};
			
		//Fade controls out
		public function fadeOut() {
			if ( this.is_playing /*&& !this.fullscreen*/ ) {
				if ( !is_faded ) {					
					this.is_faded = true;
					if ( this.fadeInEffect != null )
						this.fadeInEffect.stop();
					if ( this.fadeOutEffect != null )
						this.fadeOutEffect.stop();
					this.fadeOutEffect = new Tween( this, "alpha", Regular.easeOut, this.alpha, 0, 0.4, true);
					this.fadeOutEffect.start();
				}
			}
		}
		
		//Set the seek and redraw
		public function setSeek( seek:Number ) {
			if ( this.seek != seek ) {
				this.seek = seek;
				drawSeekFullControl();
			}
		}
				
		//Get the seek and redraw
		public function getSeek() {
			return this.seek;
		}				
		
		//Set the buffer and redraw
		public function setBuffer( buffer:Number ) {
			if ( this.buffer != buffer ) {
				this.buffer = buffer;
				drawBufferControl();
			}
		}
				
		//Get the buffer and redraw
		public function getBuffer() {
			return this.buffer;
		}
		
		//Set the volume and redraw
		public function setVolume( volume:Number ) {			
			this.volume = volume;
			drawVolumeControl();
		}
				
		//Get the volume and redraw
		public function getVolume() {
			return this.volume;
		}		
	
		//Mouse down on volume control
		public function volumeControlMouseDown( event:MouseEvent ) {
			if ( !is_disabled ) {
				stage.addEventListener( Event.MOUSE_LEAVE, volumeControlMouseLeave );
				stage.addEventListener( MouseEvent.MOUSE_MOVE, volumeControlMouseMove );
				stage.addEventListener( MouseEvent.MOUSE_UP, volumeControlMouseUp );
				if ( !volumeMouseMoving ) {
					volumeMouseMoving = true;
					dispatchEvent( new Event('volumeStart') );
					volumeControlMouseEvent( event );
				}
			}
		}
		
		//Mouse leave on volume control
		public function volumeControlMouseLeave( event:Event ) {			
			stage.removeEventListener( Event.MOUSE_LEAVE, volumeControlMouseLeave );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, volumeControlMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, volumeControlMouseUp );
			if ( volumeMouseMoving ) {
				volumeMouseMoving = false;
				dispatchEvent( new Event('volumeEnd') );				
			}
		}
		
		//Mouse up on volume control
		public function volumeControlMouseUp( event:MouseEvent ) {			
			stage.removeEventListener( Event.MOUSE_LEAVE, volumeControlMouseLeave );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, volumeControlMouseMove );
			if ( volumeMouseMoving ) {
				volumeMouseMoving = false;
				dispatchEvent( new Event('volumeEnd') );
				volumeControlMouseEvent( event );
			}
		}
		
		//Mouse move on volume control
		var volumeMouseMoving:Boolean = false;
		public function volumeControlMouseMove( event:MouseEvent ) {
			if  ( volumeMouseMoving ) 
				volumeControlMouseEvent( event );
		}
		
		//Set volume from mouse event
		public function volumeControlMouseEvent( event:MouseEvent ) {			
			var hit = event.stageX - ( x + this.volumeControl.x ),
				min = 0,
				max = this.volumeControlWidth - this.volumeNubRadius * 2;
			hit = hit <= 0 ? 0 : hit;
			hit = hit >= ( max - min ) ? ( max - min ) : hit;
			
			this.setVolume( hit / ( max - min ) );
			dispatchEvent( new Event("volumeChange") );
		}
		
		//Mouse down on seek control
		public function seekControlMouseDown( event:MouseEvent ) {
			if ( !is_disabled ) {
				stage.addEventListener( Event.MOUSE_LEAVE, seekControlMouseLeave );
				stage.addEventListener( MouseEvent.MOUSE_MOVE, seekControlMouseMove );
				stage.addEventListener( MouseEvent.MOUSE_UP, seekControlMouseUp );
				if ( !seekMouseMoving ) {
					seekMouseMoving = true;
					dispatchEvent( new Event('seekStart') );
					seekControlMouseEvent( event );
				}
			}
		}
		
		//Mouse leave on seek control
		public function seekControlMouseLeave( event:Event ) {			
			stage.removeEventListener( Event.MOUSE_LEAVE, seekControlMouseLeave );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, seekControlMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, seekControlMouseUp );
			if ( seekMouseMoving ) {
				seekMouseMoving = false;
				dispatchEvent( new Event('seekEnd') );				
			}
		}
		
		//Mouse up on seek control
		public function seekControlMouseUp( event:MouseEvent ) {			
			stage.removeEventListener( Event.MOUSE_LEAVE, seekControlMouseLeave );
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, seekControlMouseMove );
			if ( seekMouseMoving ) {
				seekMouseMoving = false;
				dispatchEvent( new Event('seekEnd') );
				seekControlMouseEvent( event );
			}
		}
	
		//Mouse move on seek control
		var seekMouseMoving:Boolean = false;
		public function seekControlMouseMove( event:MouseEvent ) {
			if ( seekMouseMoving )
				seekControlMouseEvent( event );
		}
		
		//Set seek from mouse event
		public function seekControlMouseEvent( event:MouseEvent ) {
			var hit = event.stageX - ( x + this.seekControl.x ),
				min = 0,
				max = this.seekControlWidth - this.seekNubWidth;
			hit = hit <= 0 ? 0 : hit;
			hit = hit >= ( max - min ) ? ( max - min ) : hit;
						
			this.setSeek( hit / ( max - min ) );
			dispatchEvent( new Event("seekChange") );
		}		
		
		//Set the controls bar disabled/enabled
		public function setDisabled( is_disabled:Boolean ) {			
			this.is_disabled = is_disabled;
			this.resize( this.width_, this.height_ );
		}
		
		//Get the disabled/enabled status
		public function getDisabled() {
			return this.is_disabled;
		}		
		

	}
	
}
