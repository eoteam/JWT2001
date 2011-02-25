package com.pentagram.controller
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.services.interfaces.IAppService;
	
	import flash.display.NativeWindow;
	
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
		
		[Inject]
		public var instanceModel:InstanceWindowsProxy;
		
		override public function execute():void
		{
			appModel.user = null;
			if(!NativeWindow.supportsMenu) {
				instanceModel.clientMenuItem.enabled =  instanceModel.userMenuItem.enabled = instanceModel.countriesMenuItem.enabled = false;
			}
		}
	}
}