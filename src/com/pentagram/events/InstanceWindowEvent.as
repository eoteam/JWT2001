package com.pentagram.events
{
	import flash.events.Event;
	
	public class InstanceWindowEvent extends Event
	{
		public static const CREATE_WINDOW:String = "createInstanceWindow";
		public static const WINDOW_ADDED:String = "instanceWindowAdded";
		public static const WINDOW_CLOSED:String = "instanceWindowClosed";
		public static const WINDOW_REMOVED:String = "instanceWindowRemoved";
		
		public static const INIT_INSTANCE:String = "initInstance";
		
		public static const WINDOW_FOCUS:String = "windowFocus";
		
		public static const WINDOW_TILE:String = "windowTile";
		public var uid:String;
		public var args:Array;
		
		public function InstanceWindowEvent(type:String, uid:String = null, ...args)
		{
			this.uid = uid;
			this.args = args;
			super(type, true, true);
		}
		
		override public function clone():Event
		{
			return new InstanceWindowEvent(this.type, this.uid, this.args);
		}
	}
}