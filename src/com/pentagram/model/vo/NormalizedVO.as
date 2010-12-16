package com.pentagram.model.vo
{
	[Bindable]
	public class NormalizedVO
	{
		public var x:*;
		public var y:*;
		public var radius:Number;
		public var color:uint;
		public var name:String;
		public var index:int;
		public var alpha:Number=.7;
		
		public var prevRadius:Number;
		
		public var xData:DataRow;
		public var yData:DataRow;
		public var rData:DataRow;
		public var cData:DataRow;
	}
}