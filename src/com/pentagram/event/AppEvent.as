package com.pentagram.event
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const STARTUP:String = "startup";
		public static const STARTUP_COMPLETE:String = "startupComplete";
		public static const STARTUP_PROGRESS:String = "startupProgress";
		
		public static const LOGGEDIN:String = "loggedin";
		public static const LOGOUT:String = "logout";
		public static const LOGIN_ERROR:String = "loginError";
		
		public static const TIMED_OUT:String = "timedout";
		public static const BOOTSTRAP_COMPLETE:String = "bootStrapComplete";
		
		//public static const INIT:String = "init";	
		
		public var args:Array;
		public function AppEvent(type:String,...args)
		{
			this.args = args;
			super(type,true,true);
		}
		override public function clone() : Event
		{
			return new AppEvent(this.type,this.args);
		}
	}
}