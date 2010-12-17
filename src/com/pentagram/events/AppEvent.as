package com.pentagram.events
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const STARTUP_BEGIN:String = "startupBegin";
		public static const STARTUP_COMPLETE:String = "startupComplete";
		public static const STARTUP_PROGRESS:String = "startupProgress";
		
		public static const LOGIN:String = "login";
		public static const LOGGEDIN:String = "loggedin";
		public static const LOGGEDOUT:String = "loggedout";
		public static const LOGIN_ERROR:String = "loginError";
		
		public static const TIMED_OUT:String = "timedout";
		public static const BOOTSTRAP_COMPLETE:String = "bootStrapComplete";
		
		
		 //slide show event
		

		
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