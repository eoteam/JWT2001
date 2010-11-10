package com.pentagram.instance.model.vo
{
	[Bindable]
	public class Year
	{
		public var year:int;
		public var selection:Number;
		
		public function Year(y:int,s:Number) {
			this.year = y;
			this.selection = s;
		}
	}
}