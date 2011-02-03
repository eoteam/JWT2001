package com.pentagram.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.services.interfaces.IClientService;
	
	import org.robotlegs.mvcs.Command;
	
	public class DeleteClientCommand extends Command
	{
		[Inject]
		public var event:EditorEvent;
		
		[Inject]
		public var service:IClientService;
		
		override public function execute():void {
			service.removeClient(
		}
	}
}