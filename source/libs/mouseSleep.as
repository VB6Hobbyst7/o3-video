/*
O3 Video Player Mouse Action Checker
libs.mouseSleep
Created by Zoltan Lengyel-Fischer (2014)
*/

package libs {
	
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class mouseSleep extends MovieClip {
		
		var time_:Timer;
	
		//Constructor
		//@param msec_:Number Milliseconds
		public function mouseSleep( msec_:Number ) {
			this.time_ = new Timer( msec_, 1 );
			this.time_.addEventListener( TimerEvent.TIMER, this.triggerSleep );			
		}
		
		//Start the timer
		public function run() {
			this.time_.stop();
			this.time_.start();
		}
		
		//Trigger event if no mouse move
		public function triggerSleep( event:TimerEvent ) {
			dispatchEvent( new Event('sleep') );
		}	

	}
	
}
