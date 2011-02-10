package com.pentagram.instance.model
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.NormalizedVO;
	import com.pentagram.model.vo.User;
	
	import flash.display.NativeMenuItem;
	import flash.filesystem.File;
	
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
		
		public var maxRadius:Number = 25;
		
		
		public var exportDirectory:File;
		public var includeHeader:Boolean = true;
		public var includeTools:Boolean = true;
		
		public var isCompare:Boolean = false;
		public var compareArgs:Array;
		
		public const LOGIN_WINDOW:String = "loginWindow";
		public const SPREADSHEET_WINDOW:String = "spreadsheetWindow";
		
		
		
		public const MAP_INDEX:int = 2;
		public const CLUSTER_INDEX:int = 0;
		public const GRAPH_INDEX:int = 1;
		public const TWITTER_INDEX:int = 3;

		public function parseData(data:Array,dataset:Dataset,client:Client):void {
			var prop:String;
			var item:Object;
			var row:DataRow;
			
			for each(var country:Country in client.countries.source) {
				for each(item in data) {
					if(item.countryid == country.id.toString()) {
						row = new DataRow();
						row.name = country.name;
//						row.xcoord = country.xcoord;
//						row.ycoord = country.ycoord;
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
		public function normalizeData(categories:Array,ds1:Dataset,ds2:Dataset,ds3:Dataset=null,ds4:Dataset=null):ArrayCollection {
			var data:ArrayCollection = new ArrayCollection();;
			for (var i:int=0;i<ds1.rows.length;i++) {
				var row:DataRow = ds1.rows.getItemAt(i) as DataRow;
				var obj:NormalizedVO = new NormalizedVO(); 
				obj.name = row.name;
				obj.shortname = row.country.shortname;
				obj.country = row.country;
				obj.index = i;
				
				if(ds1.time == 1) 
					obj.x = ds1.rows.getItemAt(i)[ds1.years[0]];
				else
					obj.x = ds1.rows.getItemAt(i).value;
				
				if(ds2.time == 1) 
					obj.y = ds2.rows.getItemAt(i)[ds2.years[0]];
				else
					obj.y = ds2.rows.getItemAt(i).value;
				
				
				if(ds3) {
					var row2:DataRow = ds3.rows.getItemAt(i) as DataRow;
					if(ds3.time == 1)
						obj.radius = obj.prevRadius = (row2[ds3.years[0]] - ds3.min) / (ds3.max - ds3.min);
					else
						obj.radius = obj.prevRadius = (row2.value - ds3.min) / (ds3.max - ds3.min);
				}
				else
					obj.radius = obj.prevRadius = obj.prevRadius = 10;
				
				if(ds4) {
					var value:String;
					if(ds4.time == 1) 
						value = ds4.rows.getItemAt(i)[ds4.years[0]];
					else
						value = ds4.rows.getItemAt(i).value;
					obj.color = ds4.colorArray[value];	
					obj.category = value;
				}
				else {
					obj.color = ds1.rows.getItemAt(i).color;
					obj.category = row.country.region.name;
				}
				if(categories.indexOf(obj.category) != -1)
					obj.radius = obj.prevRadius;
				else
					obj.radius = 0;
				data.addItem(obj);
			}
			return data;
		}
		public function updateData(categories:Array,data:ArrayCollection,year:int,...datasets):void {
			var dataset:Dataset;
			var row:DataRow;
			for each(var item:NormalizedVO in data) {
				if(Dataset(datasets[0]).time == 1)
					item.x =  Dataset(datasets[0]).rows.getItemAt(item.index)[year];
				if(Dataset(datasets[1]).time == 1)	
					item.y =  Dataset(datasets[1]).rows.getItemAt(item.index)[year];
				
				if(datasets[2] && Dataset(datasets[2]).time == 1) {
					dataset = datasets[2] as Dataset;
					row = dataset.rows.getItemAt(item.index) as DataRow;
					item.radius = item.prevRadius = (row[year] - dataset.min) / (dataset.max - dataset.min) + maxRadius/100;
				}	
				if(datasets[3] &&  Dataset(datasets[3]).time == 1) {
					dataset = datasets[3] as Dataset;
					row = dataset.rows.getItemAt(item.index) as DataRow;
					var value:String = row[year];
					item.color = dataset.colorArray[value];
					item.category = value;
				}
				if(categories.indexOf(item.category) != -1)
					item.radius = item.prevRadius;
				else
					item.radius = 0;
			}
		}
		
	}
}