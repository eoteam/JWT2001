package com.pentagram.model.vo
{
	import mx.collections.ArrayList;

	[Bindable]
	public class Country extends BaseVO
	{
		public var shortname:String;
		public var xcoord:Number;
		public var ycoord:Number;
		public var descriptiom:String;
		public var thumb:String;
		public var region:Region;
		public var altnames:String;
		//public var width:Number
		
		public var alternateNames:ArrayList = new ArrayList();
		//session info,
		public var isNew:Boolean = true;

	}
}