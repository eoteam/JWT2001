package com.pentagram.controller
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.services.interfaces.IAppService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class AuthenticateUserCommand extends Command
	{
		[Inject]
		public var appService:IAppService;
		
		[Inject]
		public var event:AppEvent;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function execute():void
		{
			appService.authenticateUser(event.args[0],event.args[1]);
			appService.addHandlers(handleUserAuthentication);
		}
		private function handleUserAuthentication(event:ResultEvent):void {	
			var results:Array = event.token.results as Array;
			if(results.length > 0) {
				appModel.user = results[0];
				eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGGEDIN,appModel.user));		
				//update last login
//				var today:Date = new Date();
//				var params:Object = new Object();
//				params.lastlogin = Math.round(today.time/1000).toString();
//				params.action = "updateRecord";
//				params.tablename = "user";
//				params.id = appModel.user.id;
//				this.createService(params,ResponseType.STATUS)
			}
			else
				eventDispatcher.dispatchEvent(new AppEvent(AppEvent.LOGIN_ERROR));
		}
	}
}