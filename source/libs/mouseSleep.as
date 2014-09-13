package libs {
	
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class mouseSleep extends MovieClip {
		
		var time_:Timer;

		public function mouseSleep( sec_ ) {
			this.time_ = new Timer( sec_, 1 );
			this.time_.addEventListener( TimerEvent.TIMER, this.triggerSleep );			
		}
		
		public function run() {
			this.time_.stop();
			this.time_.start();
		}
		
		public function triggerSleep( event:TimerEvent ) {
			dispatchEvent( new Event('sleep') );
		}	

	}
	
}
