package com.pentagram.view.event
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		public static const CLIENT_SELECTED:String = "clientSelected";
		public static const SHELL_LOADED:String = "shellLoaded";
		
		public var args:Array;
		public function ViewEvent(type:String,...args)
		{
			this.args = args;
			super(type,true,true);
		}
		override public function clone() : Event
		{
			return new ViewEvent(this.type,this.args);
		}
	}
}