package com.pentagram.view.event
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		public static const CLIENT_SELECTED:String = "clientSelected";
		public static const SHELL_LOADED:String = "shellLoaded";
		public static const DATASET_CREATOR_COMPLETE:String = "datasetCreatorComplete";
		
		public static const CELL_SELECTED:String  = "cellSelected";
		
		public static const CLIENT_PROP_CHANGED:String = "clientPropChanged";
		
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