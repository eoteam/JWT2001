package com.pentagram.instance.model.vo
{
	[Bindable]
	public class Year
	{
		public var year:String;
		public var selection:Number;
		public var alpha:uint = 1;
		public var label:String;
		
		public function Year(y:String,l:String,s:Number) {
			this.year = y;
			this.label = l;
			this.selection = s;
		}
	}
}