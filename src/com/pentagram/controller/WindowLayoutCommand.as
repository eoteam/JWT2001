package com.pentagram.controller
{
	import com.pentagram.model.InstanceWindowsProxy;
	
	import org.robotlegs.mvcs.Command;
	
	public class WindowLayoutCommand extends Command
	{
		[Inject]
		public var instanceModel:InstanceWindowsProxy;
		
		override public function execute():void {
			instanceModel.tile();
		}
	}
}