package com.pentagram.controller.configuration
{
	import mx.core.FlexGlobals;
	
//	import org.mig.events.AppEvent;
//	import org.mig.model.AppModel;
//	import org.mig.services.interfaces.IAppService;
	import org.robotlegs.mvcs.Command;
	
	public class StartApplicationCommand extends Command
	{
//		[Inject]
//		public var service:IAppService;
//		
//		[Inject]
//		public var appModel:AppModel;
//		
		override public function execute():void
		{
			trace("Application Started");
			//appModel.prompt = FlexGlobals.topLevelApplication.parameters.prompt;
			//eventDispatcher.dispatchEvent(new AppEvent(AppEvent.BOOTSTRAP_COMPLETE));	
		}
	}
}