package com.pentagram.model.vo
{	
	import mx.collections.ArrayList;

	[Bindable]
	public class Region extends Category
	{

		public var countries:ArrayList;
		public var fxgmap:String;
		public var width:Number = 1;
		public var height:Number = 1;
		public var coeff:Number = 1;
		
		public var id:Number;
		public var modified:Boolean = false;
		public var modifiedProps:Array = [];
	}
}