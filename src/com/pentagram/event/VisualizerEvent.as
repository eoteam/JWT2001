package com.pentagram.event
{
	import flash.events.Event;
	
	public class VisualizerEvent extends Event
	{
		
		public static const CLIENT_SELECTED:String = "clientSelected";
		
		public var args:Array;
		public function VisualizerEvent(type:String,...args)
		{
			this.args = args;
			super(type,true,true);
		}
		override public function clone() : Event
		{
			return new VisualizerEvent(this.type,this.args);
		}
	}
}