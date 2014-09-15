/*
O3 Video Player Poster
libs.videoPoster
Created by Zoltan Lengyel-Fischer (2014)
*/

package libs {

	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	
	public class videoPoster extends MovieClip {
		
		private var width_:Number = 0;
		private var height_:Number = 0;
		private var file_:String = ''; //image file url
		private var type_:String = ''; //image file ext
		
		public var contentloader = new Loader();
		
		//Flag if need to be showed
		private var show_ = true;
		
		//Background image
		private var bgImage:Bitmap = new Bitmap();
		
		//Constructor
		public function videoPoster( width_, height_ ) {
			//Set dimension
			this.width_ = width_;
			this.height_ = height_;
			
			//Add content loader
			//this.addChild(this.contentloader);
			
			//Set hidden
			this.visible = false;
		}
		
		//Show object if loaded
		public function show() {
			this.show_ = true;			
		}
		
		//Hide object
		public function hide() {
			this.show_ = false;
			//Stop loading
			try{
			 	this.contentloader.close();
			} catch(e:Error){}			
			this.visible = false;
		}
		
		//Set the video/audio file 
		public function setFile( file ) {
			this.file_ = file;
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
			this.contentloader.load( new URLRequest( this.file_ ), contentloaderContext );						
		}
		
		//Loading done
		private function loadingDone( event:Event ) {
			this.resize( this.width_, this.height_ );			
			this.visible = this.show_;
		}
		
		//Loading error
		private function loadingError( event:IOErrorEvent ) {
			this.visible = false;
		}	
		
		//Reposition/resize object
		public function resize( width:Number, height:Number ) {
			this.width_ = width;
			this.height_ = height;
			
			if ( this.contentloader.width && this.contentloader.height ) {
				
				var matrix:Matrix = new Matrix();
				matrix.scale(1, 1);
				
				var bitmapDataTemp = new BitmapData( this.contentloader.width, this.contentloader.height, true, 0xFFFFFF );
				bitmapDataTemp.draw( this.contentloader, matrix, null, null, null, true );
								
				if ( this.contains( this.bgImage ))
					this.removeChild(this.bgImage);	
				
				this.bgImage = new Bitmap( this.resizeImage( bitmapDataTemp, this.width_, this.height_, true ), "auto", true );
				this.bgImage.x = ( this.width_ - this.bgImage.width ) / 2;
				this.bgImage.y = ( this.height_ - this.bgImage.height ) / 2;
				
				if (this.contains(this.bgImage))
					this.removeChild(this.bgImage);
				this.addChild(this.bgImage)
				
			}
		}
				
		//Resize image
		function resizeImage( source:BitmapData, width:uint, height:uint, constrainProportions:Boolean = true ):BitmapData {
			var IDEAL_RESIZE_PERCENT:Number = 0.5,
				scaleX:Number = width/source.width,
				scaleY:Number = height/source.height;
			if (constrainProportions) {
				if (scaleX > scaleY) scaleX = scaleY;
				else scaleY = scaleX;
			}
		
			var bitmapData:BitmapData = source;
		
			if (scaleX >= 1 && scaleY >= 1) {
				bitmapData = new BitmapData(Math.ceil(source.width*scaleX), Math.ceil(source.height*scaleY), true, 0);
				bitmapData.draw(source, new Matrix(scaleX, 0, 0, scaleY), null, null, null, true);
				return bitmapData;
			}
		
			//Scale it by the IDEAL for best quality
			var nextScaleX:Number = scaleX;
			var nextScaleY:Number = scaleY;
			while (nextScaleX < 1) nextScaleX /= IDEAL_RESIZE_PERCENT;
			while (nextScaleY < 1) nextScaleY /= IDEAL_RESIZE_PERCENT;
		
			if (scaleX < IDEAL_RESIZE_PERCENT) nextScaleX *= IDEAL_RESIZE_PERCENT;
			if (scaleY < IDEAL_RESIZE_PERCENT) nextScaleY *= IDEAL_RESIZE_PERCENT;
		
			var temp:BitmapData = new BitmapData(bitmapData.width*nextScaleX, bitmapData.height*nextScaleY, true, 0);
			temp.draw(bitmapData, new Matrix(nextScaleX, 0, 0, nextScaleY), null, null, null, true);
			bitmapData = temp;
		
			nextScaleX *= IDEAL_RESIZE_PERCENT;
			nextScaleY *= IDEAL_RESIZE_PERCENT;
		
			while (nextScaleX >= scaleX || nextScaleY >= scaleY) {
				var actualScaleX:Number = nextScaleX >= scaleX ? IDEAL_RESIZE_PERCENT : 1;
				var actualScaleY:Number = nextScaleY >= scaleY ? IDEAL_RESIZE_PERCENT : 1;
				temp = new BitmapData(bitmapData.width*actualScaleX, bitmapData.height*actualScaleY, true, 0);
				temp.draw(bitmapData, new Matrix(actualScaleX, 0, 0, actualScaleY), null, null, null, true);
				bitmapData.dispose();
				nextScaleX *= IDEAL_RESIZE_PERCENT;
				nextScaleY *= IDEAL_RESIZE_PERCENT;
				bitmapData = temp;
			}
		
			return bitmapData;
		}
		
	}
	
}
