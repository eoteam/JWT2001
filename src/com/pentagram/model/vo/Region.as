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
	}
}