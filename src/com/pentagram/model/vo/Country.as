package com.pentagram.model.vo
{
	[Bindable]
	public class Country extends BaseVO
	{
		public var shortname:String;
		public var xcoord:Number;
		public var ycoord:Number;
		public var descriptiom:String;
		
		public var thumb:String;
		public var continent:Continent;

		
		//session info,
		public var isNew:Boolean = true;

	}
}