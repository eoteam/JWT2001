package com.pentagram.model
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	
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
		
		public var selectedClient:Client;
		public var selectedSet:Dataset;
		
		public var loggedIn:Boolean = false;
		
		public var user:User;
		
		//global ref
		//public var
	}
}