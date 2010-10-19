package com.pentagram.view.event
{
	import flash.events.Event;

	public class DataPromptEvent extends Event
	{
		public function DataPromptEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static const TIME_TYPE_NEXT:String = "timeTypeNext";
		public static const TIME_TYPE_BACK:String = "timeTypeBack";
		
		public static const TIME_RANGE_NEXT:String = "timeRangeNext";
		public static const TIME_RANGE_BACK:String = "timeRangeBack";
		
		public static const DATA_TYPE_NEXT:String = "dataTypeNext";
		public static const DATA_TYPE_BACK:String = "dataTypeBack";
		
		public static const UNITS_NEXT:String = "unitsNext";
		public static const UNITS_BACK:String = "unitsBack";
		
		public var data:*;
		
	}
}