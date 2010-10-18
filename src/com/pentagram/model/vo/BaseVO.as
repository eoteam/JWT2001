package com.pentagram.model.vo
{
	[Bindable]
	internal class BaseVO
	{
		public var id:Number;
		public var name:String;
		public var modified:Boolean = false;
		public var modifiedProps:Array = [];
	}
}