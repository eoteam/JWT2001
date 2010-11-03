package com.pentagram.model.vo
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.utils.ObjectProxy;
	
	[Bindable]
	public dynamic class DataRow	
	{
		public var dataset:Dataset;
		public var name:String;
		public var id:int;
		public var modified:Boolean = false;
		public var value:*;
		//public var points:Dictionary = new Dictionary();
	}
}