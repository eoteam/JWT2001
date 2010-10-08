package com.pentagram.controller.configuration {
	import org.robotlegs.mvcs.Command;
	
	public class ConfigurationFailedCommand extends Command
	{
		override public function execute():void
		{
			trace("configuration failed");
		}
	}
}