package com.pentagram.event
{
	import flash.events.Event;
	
	public class AlertEvent extends Event
	{
		public static const SHOW_ALERT : String = "showAlert";
		
		public var title : String;
		
		public var message : String;
		
		public function AlertEvent( type : String, title : String, message : String )
		{
			super( type );
			this.title = title;
			this.message = message;
		}
		
		override public function clone() : Event
		{
			return new AppEvent( type, title, message );
		}
	}
}