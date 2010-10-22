package com.pentagram.model.vo
{
	import flash.utils.Dictionary;
	
	import mx.utils.ObjectProxy;
	
	[Bindable]
	public dynamic class DataRow	
	{
		public var name:String;
		public var id:int;
		public var modified:Boolean = false;
		public var points:Dictionary = new Dictionary();
	}
}