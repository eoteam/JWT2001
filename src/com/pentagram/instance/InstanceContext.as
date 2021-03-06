package com.pentagram.instance
{
	import com.pentagram.instance.controller.configuration.BootstrapInstanceCommand;
	import com.pentagram.instance.model.InstanceModel;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.sampler.getMemberNames;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	
	public class InstanceContext extends Context
	{
		public var appEventDispatcher:EventDispatcher;
		public function InstanceContext(appEventDispatcher:EventDispatcher,contextView:DisplayObjectContainer=null, autoStartup:Boolean=true)
		{
			super(contextView, autoStartup);
			this.appEventDispatcher = appEventDispatcher;
		}
		
		override public function startup():void
		{  
			injector.mapValue(EventDispatcher, appEventDispatcher, "ApplicationEventDispatcher"); 
			commandMap.mapEvent( ContextEvent.STARTUP, BootstrapInstanceCommand, ContextEvent, true );
			dispatchEvent(new ContextEvent(ContextEvent.STARTUP)); 
		}
		override public function shutdown():void {
			injector.unmap(EventDispatcher,"ApplicationEventDispatcher");
			commandMap.unmapEvents();
			injector.unmap(InstanceModel);	
			super.shutdown(); 
		}
	}
}