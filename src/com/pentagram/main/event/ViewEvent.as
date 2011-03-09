package com.pentagram.main.event
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		public static const CLIENT_SELECTED:String = "clientSelected";
		public static const SHELL_LOADED:String = "shellLoaded";
		public static const DATASET_CREATOR_COMPLETE:String = "datasetCreatorComplete";
		
		public static const CELL_SELECTED:String  = "cellSelected";
		
		public static const CLIENT_PROP_CHANGED:String = "clientPropChanged";
		
		public static const SAVE_EXPORT_SETTINGS:String = "saveExportSettings";
		
		public static const MENU_IMAGE_SAVE:String = "menuImageSave";
		public static const START_IMAGE_SAVE:String = "startSaveImage";
		public static const END_IMAGE_SAVE:String = "endSaveImage";
		
		public static const START_COMPARE:String = "startCompare";
		
		public static const WINDOW_FOCUS:String = "windowFocus";
		
		public static const WINDOW_CLEANUP:String = "cleanupWindow";
		
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