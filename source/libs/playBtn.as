package libs {

	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import libs.Base64Decoder;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
 	import fl.transitions.easing.*;
 	import fl.transitions.TweenEvent;
	
	public class playBtn extends MovieClip {
		
		private var width_:Number = 0;
		private var height_:Number = 0;
		private var file_:String = ''; //image file url
		private var type_:String = ''; //image file ext
		private var loadtype_:String = ''; //type of file loading, base64 or url
		
		public var contentloader = new Loader();
		
		//flag if need to be showed
		private var show_ = true;
		
		//mouse over effect
		var overEffect:Object = null;
				
		public function playBtn( width_, height_ ) {
			//set dimension
			this.width_ = width_;
			this.height_ = height_;
			
			//add content loader
			this.addChild(this.contentloader);
			
			//set hidden
			this.visible = false;
			this.useHandCursor = true;
			this.buttonMode = true;
			
			this.addEventListener( MouseEvent.MOUSE_OVER, this.mouseOver );
			this.addEventListener( MouseEvent.MOUSE_OUT, this.mouseOut );
			
		}
		
		private function mouseOver( event:MouseEvent ) {
			if ( this.overEffect != null )
				this.overEffect.stop();
			this.overEffect = new Tween( this, "alpha", Regular.easeOut, this.alpha, 0.5, 0.3, true);
			this.overEffect.start();
		}
		
		private function mouseOut( event:MouseEvent ) {
			if ( this.overEffect != null )
				this.overEffect.stop();
			this.overEffect = new Tween( this, "alpha", Regular.easeIn, this.alpha, 1, 0.3, true);
			this.overEffect.start();
		}
		
		//show object if loaded
		public function show() {
			this.show_ = true;			
		}
		
		//hide object
		public function hide() {
			if ( this.show_ !== false ) { 
				this.show_ = false;
				//stop loading
				try{
					this.contentloader.close();
				} catch(e:Error){}			
				
				//animate out
				var xEffect = new Tween( contentloader, "x", Regular.easeOut, contentloader.x, contentloader.x - contentloader.width, 0.5, true);
				var yEffect = new Tween( contentloader, "y", Regular.easeOut, contentloader.y, contentloader.y - contentloader.height, 0.5, true);
				var wEffect = new Tween( contentloader, "width", Regular.easeOut, contentloader.width, contentloader.width * 3, 0.5, true);
				var hEffect = new Tween( contentloader, "height", Regular.easeOut, contentloader.height, contentloader.height * 3, 0.5, true);
				var aEffect = new Tween( contentloader, "alpha", Regular.easeOut, contentloader.alpha, 0, 0.5, true);
				aEffect.addEventListener( TweenEvent.MOTION_FINISH, this.hideTweenComplete );
				
			}
		}
		
		//make visible false
		private function hideTweenComplete( event:TweenEvent ) {
			this.visible = false;
		}
		
		//set the video/audio file 
		public function setFile( file, loadtype ) {
				
			this.file_ = file;
			this.loadtype_ = loadtype;
			this.type_ = file.substr( file.lastIndexOf('.') + 1, file.length );			
			
			this.contentloader.contentLoaderInfo.removeEventListener( Event.COMPLETE, this.loadingDone );	
			this.contentloader.contentLoaderInfo.addEventListener( Event.COMPLETE, this.loadingDone );	
			
			this.contentloader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, this.loadingError );	
			this.contentloader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, this.loadingError );				
			
			var contentloaderContext:LoaderContext = new LoaderContext();
			contentloaderContext.checkPolicyFile = false;							
			
			try{
			 	this.contentloader.close();
			} catch(e:Error){}
			
			if ( loadtype == 'base64' ) {
				var bytes:ByteArray = Base64Decoder.decodeToByteArray( this.file_ );
				contentloader.loadBytes( bytes );
			} else {
				contentloader.load( new URLRequest( this.file_ ), contentloaderContext );
			}
		}
		
		//loading done
		private function loadingDone( event:Event ) {
			this.resize( this.width_, this.height_ );			
			this.visible = this.show_;
		}
		
		//loading error
		private function loadingError( event:IOErrorEvent ) {
			this.visible = false;
		}	
		
		//reposition/resize object
		public function resize( width:Number, height:Number ) {
			this.width_ = width;
			this.height_ = height;
			this.x = ( this.width_ - this.contentloader.width ) / 2;
			this.y = ( this.height_- this.contentloader.height ) / 2;
		}
	}
	
}
