package com.pentagram.model.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class Dataset extends BaseVO
	{

		public var contentid:int;
		public var unit:String='';
		public var multiplier:Number=0;
		public var time:int;
		public var type:int;
		public var tablename:String; //name of table
		public var description:String;
		
		public var options:String; //for qualitative type
		
		//public var data:String; //content of table
		public var rows:ArrayCollection;
		public var columns:ArrayCollection;
		
		public var loaded:Boolean = false;
		
 		public var createdby:int;
		public var modifiedby:int;
		public var createdate:int;
		public var modifieddate:int;
		public var deleted:int;
		
		
		public var years:Array;
		public var range:String;
	}
}