package com.pentagram.model.vo
{
	[Bindable]
	public class Dataset extends BaseVO
	{

		public var contentid:int;
		public var unit:String;
		public var multiplier:Number;
		public var time:int;
		public var type:int;
		public var tablename:String; //name of table
		public var options:String; //for qualitative type
		
		public var data:String; //content of table
		public var loaded:Boolean = false;
		
 		public var createdby:int;
		public var modifiedby:int;
		public var createdate:int;
		public var modifieddate:int;
		public var deleted:int;
		
		
		public var years:Array;
		
	}
}