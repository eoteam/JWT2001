package com.pentagram.model.vo
{	
	import mx.collections.ArrayList;

	[Bindable]
	public class Region extends BaseVO
	{
		public var color:uint;
		public var countries:ArrayList;
		public var selected:Boolean = true;
		public var fxgmap:String;
		public var enabled:Boolean = true;
		public var width:Number = 1;
		public var height:Number = 1;
		public var coeff:Number = 1;
	}
}