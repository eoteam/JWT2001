package com.pentagram.view.mediators
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.InstanceWindowsProxy;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.view.event.ViewEvent;
	import com.pentagram.view.windows.ExportSpreadSheetWindow;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class ExportSpreadSheetWindowMediator extends Mediator
	{
		public function ExportSpreadSheetWindowMediator()
		{
			super();
		}
		[Inject]
		public var view:ExportSpreadSheetWindow;

		[Inject]
		public var instanceWindows:InstanceWindowsProxy;
		
		
		private var fr:FileReference;
		override public function onRegister():void
		{
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
			eventMap.mapListener(view, ViewEvent.DATASET_CREATOR_COMPLETE, handleSaveFile,ViewEvent,false,0,true);
		}
		protected function handleWindowClose(event:Event):void
		{
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.WINDOW_CLOSED, view.id)); 
			mediatorMap.removeMediator(this);
		}	
		private function handleSaveFile(event:ViewEvent):void
		{
			var content:String = 'Country,';
			var line:String = '';
			if(view.dataset.time == 1) {
				for(var i:int=view.dataset.years[0]; i <= view.dataset.years[1]; i++) {
					content += i.toString()+',';
					line +=',';
				}
				content = content.substr(0,content.length-1);
			}
			else {
				content += 'Value';
				line = ',';
			}
			content += "\r\n";
			var client:Client;// =  instanceWindows.currentWindow.instance.client.countries.source
			for each(var country:Country in client.countries.source) {
				content += '"'+country.name+'"'+line+'\r\n';
			}
			
			fr = new FileReference();
			fr.addEventListener(Event.COMPLETE, onFileSave);
			fr.addEventListener(Event.CANCEL,onCancel);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			fr.save(content, view.titlePrompt.title+'.csv');
			view.close();
		}
		
		/***** File Save Event Handlers ******/
		
		//called once the file has been saved
		private function onFileSave(e:Event):void
		{
			
			trace("File Saved");
			fr = null;
			view.reset();
		}
		
		//called if the user cancels out of the file save dialog
		private function onCancel(e:Event):void
		{
			trace("File save select canceled.");
			fr = null;
		}
		
		//called if an error occurs while saving the file
		private function onSaveError(e:IOErrorEvent):void
		{
			trace("Error Saving File : " + e.text);
			fr = null;
		}
	}
}