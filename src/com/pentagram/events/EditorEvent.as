package com.pentagram.events
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static const UPDATE_CLIENT_DATA:String = "updateClientData";
		public static const CLIENT_DATA_UPDATED:String = "clientDataUpdated";
		public static const CREATE_CLIENT:String = "createClient";
		public static const CLIENT_CREATED:String = "clientCreated";
		public static const DELETE_CLIENT:String = "deleteClient";
		public static const CLIENT_DELETED:String = "clientDeleted";
		
		public static const CREATE_DATASET:String = "createDataset";
		public static const DUMP_DATASET_DATA:String = "dumpDatasetData";
		public static const DATASET_CREATED:String = "datasetCreated";
		
		public static const DELETE_DATASET:String = "deleteDataset";
		public static const DATASET_DELETED:String = "datasetDeleted";
		
		public static const UPDATE_DATASET:String = "updateDataset";
		public static const DATASET_UPDATED:String = "datasetUpdated";
		
		public static const CANCEL:String = "cancelEditor";
		
		public static const ERROR:String = "importFailed";
		public static const SELECT_IMPORT_FILE:String = "selectImportFile";
		public static const START_IMPORT:String = "startImport";
		public static const RESUME_IMPORT:String = "resumeImport";
		
		public static const NOTIFY:String = "notify";
		
		public static const UPDATE_COUNTRY:String = "updateCountry";
		public static const COUNTRY_UPDATED:String = "countryUpdated";
		public static const CREATE_COUNTRY:String = "createCountry";
		public static const COUNTRY_CREATED:String = "countryCreated";
		public static const DELETE_COUNTRY:String = "deleteCountry";
		public static const COUNTRY_DELETED:String = "countryDeleted";
		
		
		public static const UPDATE_NOTE:String = "updateNote";
		public static const NOTE_UPDATED:String = "noteUpdated";
		public static const CREATE_NOTE:String = "createNote";
		public static const NOTE_CREATED:String = "noteCreated";
		
		public static const ADD_COUNTRY_FROM_IMPORT:String = "addCountryFromImport";
		
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