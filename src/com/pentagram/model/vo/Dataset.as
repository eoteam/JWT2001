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
		public var name:String; 
		public var tablename:String; //name of table
		
		public var data:ArrayCollection; //content of table
		public var options:Array; //for qualitative type
		public var optionsMap:Array;
		public var loaded:Boolean = false;
		
		public var max:Number = 0;
		public var min:Number = -1;
		
		
	}
}