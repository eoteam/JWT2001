package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Note;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IClientService;

	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpdateNoteCommand extends Command
	{
		[Inject]
		public var event:EditorEvent;
		
		[Inject]
		public var service:IClientService;
		
		[Inject]
		public var model:InstanceModel;
		
		private var note:Note;
		
		override public function execute():void {
			note = event.args[0] as Note;	
			service.updateNote(note);
			service.addHandlers(handleNoteSaved);
		}
		private function handleNoteSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.NOTE_UPDATED));
			}
		}
	}
}