package com.pentagram.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.IUIComponent;
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;

	public class ModuleUtil extends EventDispatcher
	{
		public function ModuleUtil()
		{
		}
	
		public var info:IModuleInfo;
		public var view:IUIComponent;
		
		public function loadModule(url:String):void {
			info = ModuleManager.getModule(url);
			if (info != null) {
				info.addEventListener(ModuleEvent.READY, modEventHandler);
				info.addEventListener(ModuleEvent.ERROR, modErrorHandler);
				info.load();
			}
		}
		private function modEventHandler(e:ModuleEvent):void {
			//instantiate an add the module to the UI
			info.removeEventListener(ModuleEvent.READY, modEventHandler);
			info.removeEventListener(ModuleEvent.ERROR, modErrorHandler);
			if (view == null) {
				view = info.factory.create() as IUIComponent;
				if (view != null) {
					view.x = 0;
					view.y = 0;
					view.percentWidth = 100;
					view.percentHeight = 100;
					this.dispatchEvent(new Event("moduleLoaded"));
					//graphHolder.addElement(graphView as Group);
				}
			}
		}    
		
		//module loading failure handler
		private function modErrorHandler(event:ModuleEvent):void {
			//cleanup and display an error alert
			info.removeEventListener(ModuleEvent.READY, modEventHandler);
			info.removeEventListener(ModuleEvent.ERROR, modErrorHandler);
			info = null;
			//Alert.show(event.toString(), "Error Loading Module");
			unloadModule();
		}
		
		//Remove from UI and unload the module
		public function unloadModule():void {
			//moduleContainer.removeAllChildren();
			if (view != null && info != null) {
				info.addEventListener(ModuleEvent.UNLOAD, unloadEventHandler);
				info.unload();
			}
		}
		
		//Module unload complete event handler
		private function unloadEventHandler(e:ModuleEvent):void {
			info.removeEventListener(ModuleEvent.UNLOAD, unloadEventHandler);
			view = null;
			info = null;
		}		
		
		
	}
}