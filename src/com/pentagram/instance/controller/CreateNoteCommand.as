package com.pentagram.instance.controller
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.model.vo.Note;
	import com.pentagram.services.StatusResult;
	import com.pentagram.services.interfaces.IClientService;
	
	import mx.rpc.events.ResultEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class CreateNoteCommand extends Command
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
			service.createNode(note);
			service.addHandlers(handleNoteSaved);
		}
		private function handleNoteSaved(event:ResultEvent):void {
			var result:StatusResult = event.token.results as StatusResult;	
			if(result.success) {
				note.id = Number(result.message);
				model.client.notes.addItem(note);
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.NOTE_CREATED));
			}
		}
	}
}