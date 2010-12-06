package com.pentagram.utils
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="executed", type="flash.events.Event")] 
	public class CallTimer extends Timer
	{
		public var fc:Function;
		public var args:Array;
		
		public function CallTimer(fc:Function,args:Array,delay:Number, repeatCount:int=1)
		{
			super(delay, repeatCount);
			this.fc = fc;
			this.args = args;
			this.addEventListener(TimerEvent.TIMER_COMPLETE,execute);
		}
		protected function execute(event:TimerEvent):void {
			if(args)
				fc.call(null,args);
			else
				fc.call();
			this.dispatchEvent(new Event("executed"));
		}
	}
}