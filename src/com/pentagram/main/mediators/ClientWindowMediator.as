package com.pentagram.main.mediators
{
	import com.pentagram.events.BaseWindowEvent;
	import com.pentagram.events.EditorEvent;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.main.windows.ClientListWindow;
	import com.pentagram.model.AppModel;
	import com.pentagram.model.vo.Client;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	
	public class ClientWindowMediator extends Mediator
	{
		[Inject]
		public var view:ClientListWindow;
		
		[Inject]
		public var appModel:AppModel;
		
		override public function onRegister():void
		{
			eventMap.mapListener(view, Event.CLOSE, handleWindowClose,Event,false,0,true);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientDataUpdated,EditorEvent);
			view.saveBtn.addEventListener(MouseEvent.CLICK,handleSaveChanges,false,0,true);
			this.addViewListener(ViewEvent.CLIENT_PROP_CHANGED,handlePropChange,ViewEvent);
			view.clients = appModel.clients;
		}
		private function handleWindowClose(event:Event):void
		{
			eventDispatcher.dispatchEvent(new BaseWindowEvent(BaseWindowEvent.WINDOW_CLOSED, view.id));
			mediatorMap.removeMediator(this);
		}
		private function handlePropChange(event:ViewEvent):void {
			var prop:String = event.args[0] as String;
			var value:String = event.args[1] as String;
			var client:Client = event.args[2] as Client;
			if(client.modifiedProps.indexOf(prop) == -1) {
				client.modifiedProps.push(prop);
			}
			client[prop] = value;
			client.modified = true;
		}
		private function handleSaveChanges(event:MouseEvent):void {
			if(view.currentState == "view") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_CLIENT_DATA,view.client));
			}
			else if(view.currentState == "create") {
				eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_CLIENT));  
			}
		}
		private function handleClientDataUpdated(event:EditorEvent):void {
			view.statusModule.updateStatus("Client Data Updated");
		}
	}
}