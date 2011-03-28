package com.pentagram.model.vo
{
	import mx.collections.ArrayList;

	[Bindable]
	public class TwitterTopic
	{
		public var value:String;
		public var count:int;
		public var selected:Boolean = true;
		public var link:Boolean = false;
		public var color:uint = 0x5599BB;
		public var tweets:ArrayList = new ArrayList();
	}
}