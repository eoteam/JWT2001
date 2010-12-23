package com.pentagram.instance.view.mediators.editor
{
	import com.pentagram.events.EditorEvent;
	import com.pentagram.instance.events.VisualizerEvent;
	import com.pentagram.instance.model.InstanceModel;
	import com.pentagram.instance.view.editor.OverviewEditor;
	import com.pentagram.instance.view.editor.RegionDrawer;
	import com.pentagram.main.event.ViewEvent;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.MimeType;
	import com.pentagram.model.vo.Region;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import org.flashcommander.event.CustomEvent;
	import org.robotlegs.mvcs.Mediator;
	
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	public class OverviewEditorMediator extends Mediator
	{
		[Inject]
		public var view:OverviewEditor;
		
		[Inject]
		public var model:InstanceModel;
			
		public override function onRegister():void {
			
			eventMap.mapListener(eventDispatcher,EditorEvent.CANCEL,handleCancel,EditorEvent);
			eventMap.mapListener(eventDispatcher,VisualizerEvent.CLIENT_DATA_LOADED,handleClientSelected,VisualizerEvent);
			eventMap.mapListener(eventDispatcher,EditorEvent.CLIENT_DATA_UPDATED,handleClientUpdated,EditorEvent);
			this.addViewListener(ViewEvent.CLIENT_PROP_CHANGED,handlePropChange,ViewEvent);
			
			
			view.client = model.client;
			view.countryInput.dataProvider = model.countries.source;
			view.countryInput.addEventListener(CustomEvent.SELECT,countryList_selectHandler,false,0,true);
			view.continentList.dataProvider = model.regions;	
			view.continentList.addEventListener(DropDownEvent.CLOSE,handleContinentSelection,false,0,true);		
			view.deleteBtn.addEventListener(MouseEvent.CLICK,handleDeleteCountries,false,0,true);
			view.logoHolder.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop,false,0,true);
			
			view.regionHolder.removeAllElements();
			for each(var region:Region in model.client.regions.source) {
				var drawer:RegionDrawer = new RegionDrawer();
				drawer.region = region;
				drawer.addEventListener(IndexChangeEvent.CHANGE,handleListSelection,false,0,true);
				view.regionHolder.addElement(drawer);
			}
		}
		private function handleCancel(event:EditorEvent):void {
			
		}
		private function handleClientSelected(event:VisualizerEvent):void {
			view.client = model.client;
		}
		private function handleClientUpdated(event:EditorEvent):void {
			view.countryTotal.text = "Total: "+model.client.countries.length;
		}
		private function handleContinentSelection(event:DropDownEvent):void {
			var continent:Region = view.continentList.selectedItem as Region;
			if(continent) {
				for each(var country:Country in continent.countries.source) {
					if(model.client.countries.getItemIndex(country) == -1) 
						model.client.countries.addItem(country);
					if(model.client.newCountries.getItemIndex(country) == -1) 
						model.client.newCountries.addItem(country);
					for each(var region:Region in model.client.regions.source) {
						if(region.id == country.region.id) {
							region.countries.addItem(country);
							break;
						}
					}
				}
			}
		}
		private function handleListSelection(event:IndexChangeEvent):void {
			
		}
		private function handleDeleteCountries(event:MouseEvent):void {
			for(var i:int=0;i<view.regionHolder.numElements;i++) {
				var drawer:RegionDrawer = view.regionHolder.getElementAt(i) as RegionDrawer;
				for each(var country:Country in drawer.countryList.selectedItems) {
					model.client.countries.removeItem(country);
					for each(var region:Region in model.client.regions.source) {
						if(region.id ==country.region.id) {
							region.countries.removeItem(country);
							break;
						}
					}
					if(model.client.deletedCountries.getItemIndex(country) == -1) 
						model.client.deletedCountries.addItem(country);
				}
			}
		}
		private function onDragDrop(event:NativeDragEvent):void {
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				trace("file:///" + File(files[0]).nativePath); 
				if(MimeType.getMimetype(File(files[0]).extension) == MimeType.IMAGE) {
					view.logo.source = "file:///" + File(files[0]).nativePath;
					
				}
				else {
					
				}
			}
		}
		protected function countryList_selectHandler(event:CustomEvent):void {
			if(model.client.countries.getItemIndex(event.data) == -1) {
				model.client.countries.addItem(event.data);
				model.client.newCountries.addItem(event.data);
				for each(var region:Region in model.client.regions.source) {
					if(region.id == event.data.region.id) {
						region.countries.addItem(event.data);
						break;
					}
				}
			}
		}
		protected function handlePropChange(event:ViewEvent):void {
			var prop:String = event.args[0] as String;
			var value:String = event.args[1] as String;
			if(model.client.modifiedProps.indexOf(prop) == -1) {
				model.client.modifiedProps.push(prop);
			}
			model.client[prop] = value;
			model.client.modified = true;
		}
	}
}