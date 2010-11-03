package com.pentagram.model
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;

	public class AppModel extends Actor
	{
		public function AppModel()
		{
		
		}
		
		[Bindable]
		public var regions:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		
		public var loggedIn:Boolean = false;
		
		public var user:User;
		

		
		//global ref
		//public var
	}
}