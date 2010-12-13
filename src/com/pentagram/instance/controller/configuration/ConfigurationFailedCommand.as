package com.pentagram.instance.controller.configuration {
	import org.robotlegs.mvcs.Command;
	
	public class ConfigurationFailedCommand extends Command
	{
		override public function execute():void
		{
			trace("Instance Configuration failed");
		}
	}
}