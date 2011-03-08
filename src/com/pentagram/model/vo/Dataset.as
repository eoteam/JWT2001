package com.pentagram.model.vo
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class Dataset extends BaseVO
	{
	
		//db
		public var contentid:uint;
		public var unit:String='';
		public var multiplier:Number=0;
		public var time:uint;
		public var type:uint;
		public var tablename:String; //name of table
		public var description:String;
		public var min:Number = Number.MAX_VALUE;
		public var max:Number = Number.MIN_VALUE;
		public var range:String;
		public var options:String; //for qualitative type
		
		public var minCopy:Number;
		public var maxCopy:Number;
		//state
		public var loaded:Boolean = false;
		
 		public var createdby:int;
		public var modifiedby:int;
		public var createdate:int;
		public var modifieddate:int;
		public var deleted:int;
		
		
		
		//data strucuture
		public var data:String; //content of table in JSON format
		public var rows:ArrayCollection = new ArrayCollection();
		public var optionsArray:Vector.<Category> = new Vector.<Category>();
		public var colorArray:Dictionary = new Dictionary();
		//public var columns:ArrayCollection = new ArrayCollection();
		public var years:Array;
		
	}
}