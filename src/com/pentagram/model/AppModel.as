package com.pentagram.model
{
	import mx.collections.ArrayList;

	public class AppModel
	{
		public function AppModel()
		{
		}
		
		[Bindable]
		public var continents:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
	}
}