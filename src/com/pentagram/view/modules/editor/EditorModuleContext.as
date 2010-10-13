package com.pentagram.view.modules.editor
{
	import flash.display.DisplayObjectContainer;
	import flash.system.ApplicationDomain;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.utilities.modular.mvcs.ModuleContext;
	
	public class EditorModuleContext extends ModuleContext
	{
		public function EditorModuleContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true, parentInjector:IInjector=null, applicationDomain:ApplicationDomain=null)
		{
			super(contextView, autoStartup, parentInjector, applicationDomain);
		}
		override public function startup():void
		{
			//mediatorMap.mapView(DoodadModule, DoodadModuleMediator);
	
		}
		
		override public function dispose():void
		{
			mediatorMap.removeMediatorByView(contextView);
			super.dispose();
		} 
	}
}