package com.pentagram.events
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static const UPDATE_CLIENT_DATA:String = "updateClientData";
		public static const CLIENT_DATA_UPDATED:String = "clientDataUpdated";
		
		public static const CREATE_DATASET:String = "createDataset";
		public static const DATASET_CREATED:String = "datasetCreated";
		
		public static const DELETE_DATASET:String = "deleteDataset";
		public static const DATASET_DELETED:String = "datasetDeleted";
		
		public static const UPDATE_DATASET:String = "updateDataset";
		public static const DATASET_UPDATED:String = "datasetUpdated";
		
		public static const CANCEL:String = "cancelEditor";
		
		public static const IMPORT_FAILED:String = "importFailed";
		
		public var args:Array;
		public function EditorEvent(type:String,...args)
		{
			this.args = args;
			super(type,true,true);
		}
		override public function clone() : Event
		{
			return new EditorEvent(this.type,this.args);
		}
	}
}