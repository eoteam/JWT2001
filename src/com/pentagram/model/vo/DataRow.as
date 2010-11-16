package com.pentagram.model.vo
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.utils.ObjectProxy;
	
	[Bindable]
	public dynamic class DataRow extends BaseVO	
	{
		public var dataset:Dataset;
		public var value:*;
		
		public var country:Country;
		public var xcoord:Number;
		public var ycoord:Number;
		
		//public var points:Dictionary = new Dictionary();
	}
}