package com.pentagram.instance.model
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataCell;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.NormalizedVO;
	import com.pentagram.model.vo.User;
	
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.NativeMenuItem;
	
	import mx.collections.ArrayCollection;
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
		
		public var colors:Vector.<uint>;
			
		public var client:Client;
		public var selectedSet:Dataset;
		
		public var user:User;
		
		public var exportMenuItem:NativeMenuItem;
		public var importMenuItem:NativeMenuItem;
				
		public const LOGIN_WINDOW:String = "loginWindow";
		public const SPREADSHEET_WINDOW:String = "spreadsheetWindow";
		
		public function parseData(data:Array,dataset:Dataset,client:Client):void {
			var prop:String;
			var item:Object;
			var row:DataRow;
//			var rowCell:DataCell;
//			var colCell:DataCell;
			
			for each(var country:Country in client.countries.source) {
				for each(item in data) {
					if(item.countryid == country.id.toString()) {
						row = new DataRow();
						row.name = country.name;
						row.xcoord = country.xcoord;
						row.ycoord = country.ycoord;
						row.country = country;
						row.id = Number(item.id);
						row.color = country.region.color;
						row.dataset = dataset;
						for(prop in item) { 
							if(prop != 'id' && prop != 'countryid') {
								if(dataset.time == 1)
									row[prop.toString()] = dataset.type == 1 ? Number(item[prop]) : item[prop]; 
								else row.value = dataset.type == 1 ? Number(item[prop]) : item[prop]; 
							}
						}
						dataset.rows.addItem(row);
						break;
					}
				}
			}
		}
		public function addRowToDataset(dataset:Dataset,item:Object,countries:ArrayList):void {
			
		}
		public function getCountryById(client:Client,countryid:int):Country {
			var res:Country;
			for each(var country:Country in client.countries.source) {
				if(country.id == countryid) {
					res = country;
					break;
				}
			}
			return res;
		}
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
		public function normalizeData2(ds1:Dataset,ds2:Dataset,ds3:Dataset=null,ds4:Dataset=null):ArrayCollection {
			var data:ArrayCollection = new ArrayCollection();;
			for (var i:int=0;i<ds1.rows.length;i++) {
				var row:DataRow = ds1.rows.getItemAt(i) as DataRow;
				var obj:NormalizedVO = new NormalizedVO(); 
				obj.name = row.name;
				obj.data = row;
				obj.index = i;
				
				if(ds1.time == 1) 
					obj.x = Number(ds1.rows.getItemAt(i)[ds1.years[0]]);
				else
					obj.x = Number(ds1.rows.getItemAt(i).value);
				
				if(ds2.time == 1) 
					obj.y = Number(ds2.rows.getItemAt(i)[ds2.years[0]]);
				else
					obj.y = Number(ds2.rows.getItemAt(i).value);
				if(ds3) {
					if(ds3.time == 1) 
						obj.radius = Number(ds3.rows.getItemAt(i)[ds3.years[0]]);
					else
						obj.radius = Number(ds3.rows.getItemAt(i).value);
				}
				else
					obj.radius = 1;
				if(ds4) {
					if(ds4.time == 1) 
						obj[ds4.name] = Number(ds4.rows.getItemAt(i)[ds4.years[0]]);
					else
						obj[ds4.name] = Number(ds4.rows.getItemAt(i).value);
				}
				obj.color = ds1.rows.getItemAt(i).color;
				//trace(obj[ds1.name],obj[ds2.name],obj.color);
				data.addItem(obj);
			}
			return data;
		}
		public function updateData2(data:ArrayCollection,year:int,...datasets):void {
			for each(var item:NormalizedVO in data) {
				//for each(var ds:Dataset in datasets) {
				if(Dataset(datasets[0]).time == 1)
					item.x =  Dataset(datasets[0]).rows.getItemAt(item.index)[year];
				if(Dataset(datasets[1]).time == 1)	
					item.y =  Dataset(datasets[1]).rows.getItemAt(item.index)[year];
				
				if(datasets[2] && Dataset(datasets[0]).time == 1)
					item.radius = Dataset(datasets[2]).rows.getItemAt(item.index)[year];
				//	}	
				
			}
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