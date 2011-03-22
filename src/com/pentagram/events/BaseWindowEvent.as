package  com.pentagram.events
{
	import flash.events.Event;
	
	public class BaseWindowEvent extends Event
	{
		
		public static const CREATE_WINDOW:String = "createInfoWindow";
		public static const WINDOW_ADDED:String = "infoWindowAdded";
		public static const WINDOW_CLOSED:String = "infoWindowClosed";
		public static const WINDOW_REMOVED:String = "infoWindowRemoved";
	
		public var uid:String;
		
		public function BaseWindowEvent(type:String, uid:String = null)
		{
			this.uid = uid;
			super(type, true, true);
		}
		
		override public function clone():Event
		{
			return new BaseWindowEvent(this.type, this.uid);
		}
	}
}