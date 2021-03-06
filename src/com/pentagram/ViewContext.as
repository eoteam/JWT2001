package com.pentagram
{
	import com.pentagram.controller.configuration.BootstrapApplicationCommand;
	import com.pentagram.instance.InstanceWindow;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	import org.robotlegs.utilities.modular.core.IModule;

	
	public class ViewContext extends Context
	{
		public function ViewContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
		{
			super(contextView, autoStartup);
		}
		override public function startup():void {
			commandMap.mapEvent( ContextEvent.STARTUP, BootstrapApplicationCommand, ContextEvent, true );
			dispatchEvent(new ContextEvent(ContextEvent.STARTUP));
			
		}
	}
}