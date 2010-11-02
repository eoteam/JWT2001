package com.pentagram.instance.model
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;

	public class InstanceModel extends Actor
	{
		[Bindable]
		public var continents:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		public var client:Client;
		public var selectedSet:Dataset;
		
		public var user:User;
		
		public const LOGIN_WINDOW:String = "loginWindow";
		public const SPREADSHEET_WINDOW:String = "spreadsheetWindow";
	}
}