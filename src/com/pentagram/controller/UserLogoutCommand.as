package com.pentagram.controller
{
	import com.pentagram.events.AppEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.services.interfaces.IAppService;
	
	import flash.display.NativeWindow;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
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
			var file:File = File.applicationStorageDirectory;
			file = file.resolvePath("Preferences/user.txt");
			if(file.exists) {
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes('');
				stream.close();
			}
			if(!NativeWindow.supportsMenu) {
				instanceModel.clientMenuItem.enabled =  instanceModel.countriesMenuItem.enabled = false;
				// instanceModel.userMenuItem.enabled =
			}
		}
	}
}