package com.pentagram.instance.model
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.User;
	
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.NativeMenuItem;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;

	public class InstanceModel extends Actor
	{
		[Bindable]
		public var regions:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		public var client:Client;
		public var selectedSet:Dataset;
		
		public var user:User;
		
		public var exportMenuItem:NativeMenuItem;
		public var importMenuItem:NativeMenuItem;
		
		public var windowMenu:NativeMenuItem;
		public var fileMenu:NativeMenuItem;
		
		public const LOGIN_WINDOW:String = "loginWindow";
		public const SPREADSHEET_WINDOW:String = "spreadsheetWindow";
		
		
		public function normalizeData(ds1:Dataset,ds2:Dataset,ds3:Dataset=null,ds4:Dataset=null):Array {
			var data:Array = [];
			for (var i:int=0;i<ds1.rows.length;i++) {
				var row:DataRow = ds1.rows.getItemAt(i) as DataRow;
				var obj:Object = new Object(); 
				obj.name = row.name;
				obj.index = i;
				if(ds1.time == 1) 
					obj[ds1.name] = Number(ds1.rows.getItemAt(i)[ds1.years[0]]);
				else
					obj[ds1.name] = Number(ds1.rows.getItemAt(i).value);
				
				if(ds2.time == 1) 
					obj[ds2.name] = Number(ds2.rows.getItemAt(i)[ds2.years[0]]);
				else
					obj[ds2.name] = Number(ds2.rows.getItemAt(i).value);
				if(ds3) {
					if(ds3.time == 1) 
						obj[ds3.name] = Number(ds3.rows.getItemAt(i)[ds3.years[0]]);
					else
						obj[ds3.name] = Number(ds3.rows.getItemAt(i).value);
				}
				else
					obj.size = 1;
				if(ds4) {
					if(ds4.time == 1) 
						obj[ds4.name] = Number(ds4.rows.getItemAt(i)[ds4.years[0]]);
					else
						obj[ds4.name] = Number(ds4.rows.getItemAt(i).value);
				}
				obj.color = ds1.rows.getItemAt(i).color;
				trace(obj[ds1.name],obj[ds2.name],obj.color);
				data.push(obj);
			}
			return data;
		}
		public function updateData(data:Data,year:int,...datasets):void {
			
			data.nodes.visit(function(d:DataSprite):void {
				for each(var ds:Dataset in datasets) {
					if(ds && ds.time == 1) {
						d.data[ds.name] = ds.rows.getItemAt(d.data.index)[year];
					}
				}
			});
//			
//			for each(var ds:Dataset in datasets) {
//				if(ds.time == 1) {
//					for(var i:int=0;i<ds.rows.length;i++) {
//						if(i < data.nodes.length) {
//							var node:NodeSprite = data.nodes[i] as NodeSprite;
//							
//							//node.dirty();
//						}
//					}
//				}
//			}
			
			
		}
	}
}