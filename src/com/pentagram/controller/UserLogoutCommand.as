package com.pentagram.controller
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UserLogoutCommand extends Command
	{
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:AppEvent;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function execute():void
		{
			appModel.user = null;
			
		}
	}
}