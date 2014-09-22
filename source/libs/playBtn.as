/*
O3 Video Player Overlay Play Button
libs.playBtn
Created by Zoltan Lengyel-Fischer (2014)
*/

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
		private var loader_width:Number = 0; //content loader original width
		private var loader_height:Number = 0; //content loader original height
		
		//Flag, true if play button need to be showed
		private var show_ = true;
		
		//Mouse over effect
		var overEffect:Object = null;
				
		//Constructor
		public function playBtn( width_, height_ ) {
			
			//Store dimension
			this.width_ = width_;
			this.height_ = height_;
			
			//Add content loader to MC
			this.addChild(this.contentloader);
			
			//Hide playbutton until image is loaded
			this.visible = false;
			this.useHandCursor = true;
			this.buttonMode = true;
			
			//Handles for mouse over/out
			this.addEventListener( MouseEvent.MOUSE_OVER, this.mouseOver );
			this.addEventListener( MouseEvent.MOUSE_OUT, this.mouseOut );
			
		}
		
		//Mouse over effect
		private function mouseOver( event:MouseEvent ) {
			if ( this.overEffect != null )
				this.overEffect.stop();
			this.overEffect = new Tween( this, "alpha", Regular.easeOut, this.alpha, 0.5, 0.3, true);
			this.overEffect.start();
		}
		
		//Mouse out effect
		private function mouseOut( event:MouseEvent ) {
			if ( this.overEffect != null )
				this.overEffect.stop();
			this.overEffect = new Tween( this, "alpha", Regular.easeIn, this.alpha, 1, 0.3, true);
			this.overEffect.start();
		}
		
		//Set show state true
		public function show() {
			this.show_ = true;			
		}
		
		//Hide object, show fadeout effect
		public function hide() {
			if ( this.show_ !== false ) { 
				this.show_ = false;
				//Stop loading
				try{
					this.contentloader.close();
				} catch(e:Error){}			
				
				//Animate out
				var xEffect = new Tween( contentloader, "x", Regular.easeOut, contentloader.x, contentloader.x - contentloader.width, 0.5, true);
				var yEffect = new Tween( contentloader, "y", Regular.easeOut, contentloader.y, contentloader.y - contentloader.height, 0.5, true);
				var wEffect = new Tween( contentloader, "width", Regular.easeOut, contentloader.width, contentloader.width * 3, 0.5, true);
				var hEffect = new Tween( contentloader, "height", Regular.easeOut, contentloader.height, contentloader.height * 3, 0.5, true);
				var aEffect = new Tween( contentloader, "alpha", Regular.easeOut, contentloader.alpha, 0, 0.5, true);
				aEffect.addEventListener( TweenEvent.MOTION_FINISH, this.hideTweenComplete );
				
			}
		}
		
		//Hide play button if fade out effect finished
		private function hideTweenComplete( event:TweenEvent ) {
			this.visible = false;
		}
		
		//Set the image file
		//@param file:String File URL or Base64 string
		//@param loadtype:String Base64 or URL
		public function setFile( file, loadtype = 'URL' ) {
				
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
			
			//Load image
			if ( loadtype == 'base64' ) {
				var bytes:ByteArray = Base64Decoder.decodeToByteArray( this.file_ );
				contentloader.loadBytes( bytes );
			} else {
				contentloader.load( new URLRequest( this.file_ ), contentloaderContext );
			}
		}
		
		//Image loading done
		private function loadingDone( event:Event ) {
			//Store original loader width and height
			this.loader_width = this.contentloader.width;
			this.loader_height = this.contentloader.height;
			//Recalculate button dimension and position
			this.resize( this.width_, this.height_ );			
			//Show button if needed
			this.visible = this.show_;
		}
		
		//Loading error
		private function loadingError( event:IOErrorEvent ) {
			//On error hide button
			this.visible = false;
		}	
		
		//Update dimension and size
		public function resize( width:Number, height:Number ) {
			this.width_ = width;
			this.height_ = height;
			this.x = ( this.width_ - this.contentloader.width ) / 2;
			this.y = ( this.height_- this.contentloader.height ) / 2;
		}
	}
	
}
