package com.pentagram.model
{
	import com.pentagram.model.vo.User;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;

	public class AppModel extends Actor
	{
		public function AppModel()
		{
			colors = new Vector.<uint>();
		}

		[Bindable]
		public var regions:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		public var colors:Vector.<uint>;
		public var loggedIn:Boolean = false;
		
		public var user:User;		
	}
}