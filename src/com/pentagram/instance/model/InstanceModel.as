package com.pentagram.instance.model
{
	import com.greensock.easing.Back;
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	import com.pentagram.model.vo.NormalizedVO;
	import com.pentagram.model.vo.User;
	
	import flash.display.NativeMenuItem;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	public class InstanceModel extends Actor
	{
		
		
		[Bindable]
		public var regions:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		public var singletonWindowModel:Boolean = false;
		
		public var countryNames:Dictionary;
		
		public var colors:Vector.<uint>;
			
		public var client:Client;
		public var selectedSet:Dataset;
		
		public var user:User;
		
		public var exportMenuItem:NativeMenuItem;
		public var importMenuItem:NativeMenuItem;
		public var toolBarMenuItem:NativeMenuItem;
		public var exportImageMenuItem:NativeMenuItem;
		
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
									row[prop.toString()] = dataset.type == 1 ? (item[prop] == '' ?NaN:Number(item[prop])) : item[prop]; 
								else row.value = dataset.type == 1 ? (item[prop] == '' ?NaN:Number(item[prop])) : item[prop];
							}
						}
						dataset.rows.addItem(row);
						break;
					}
				}
			}
		}
		public function orderCountries(dataset:Dataset):void {
			var sortField:SortField = new SortField();
			sortField.name = "id";
			sortField.numeric = true;
			var countrySort:Sort = new Sort();
			countrySort.fields = [sortField];
			countrySort.compareFunction = orderCountriesById;
			dataset.rows.sort = countrySort;
			dataset.rows.refresh();
		}
		private  function orderCountriesById(a:DataRow, b:DataRow,fields:Array = null):int 
		{ 	
			if (a.id < b.id)  
				return -1; 
				
			else if (a.id > b.id)  
				return 1; 
				
			else 
				return 0; 
			
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
			var data:ArrayCollection = new ArrayCollection();
			
			for (var i:int=0;i<ds1.rows.length;i++) {
				
				//getting rows
				var row:DataRow = ds1.rows.getItemAt(i) as DataRow;
				if(ds2.id != -2) {
					for each(var row2:DataRow in ds2.rows) {
						if(row2.country == row.country)
							break;
					}
				}
				if(ds3 && ds3.id != -2) {
					for each(var row3:DataRow in ds3.rows) {
						if(row3.country == row.country)
							break;
					}
				}
				if(ds4 && ds4.id != -2) {
					for each(var row4:DataRow in ds4.rows) {
						if(row4.country == row.country)
							break;
					}
				}
				
				var obj:NormalizedVO = new NormalizedVO(); 
				obj.name = row.name;
				obj.shortname = row.country.shortname;
				obj.country = row.country;
				obj.index = i;
				obj.rows = [row,row2,row3,row4];
				//ds1
				if(ds1.time == 1) 
					obj.x = ds1.rows.getItemAt(i)[ds1.years[0]];
				else if(ds1.id != -2)
					obj.x = ds1.rows.getItemAt(i).value;
				else
					obj.x = 1;

				//ds2
				if(ds2.time == 1) 
					obj.y = row2[ds2.years[0]];
				else  if(ds2.id != -2)
					obj.y = row2.value;
				else
					obj.y = 1;
				
				//ds3
				if(ds3 && ds3.id > 0) {
					if(ds3.time == 1) {
						obj.radius = obj.prevRadius = (row3[ds3.years[0]] - ds3.min) / (ds3.max - ds3.min);
						obj.radiusValue = row3[ds3.years[0]];
					}
					else {
						obj.radius = obj.prevRadius = (row3.value - ds3.min) / (ds3.max - ds3.min);
						obj.radiusValue = row3.value;
					}
				}
				else {
					obj.radius = obj.prevRadius = obj.prevRadius = maxRadius;
					obj.radiusValue = '';
				}
				
				//ds4
				if(ds4 && ds4.id != -1 && ds4.id != -2) {
					var value:String;
					if(ds4.time == 1) 
						value = row4[ds4.years[0]];
					else
						value = row4.value;
					obj.color = ds4.colorArray[value];	
					obj.category = value;
				}
				else if(ds4.id == -2) {
					obj.color = row.country.region.color;
					obj.category = row.country.region.name;
				}
				else {
					obj.color = 0;
				}
				if(categories.length > 0) {
					if(categories.indexOf(obj.category) != -1)
						obj.radius = obj.prevRadius;
					else
						obj.radius = 0;
				}
				data.addItem(obj);
			}
			return data;
		}
		public function updateData(categories:Array,data:ArrayCollection,year:String,...datasets):void {
			var dataset:Dataset;
			var row:DataRow;
			for each(var item:NormalizedVO in data) {
				
				if(Dataset(datasets[0]).time == 1)
					item.x =  item.rows[0][year];
				else if(Dataset(datasets[0]).id != -1)
					item.x = item.x =  item.rows[0].value;
				
				if(Dataset(datasets[1]).time == 1)	
					item.y =  item.rows[1][year];
				else  if(Dataset(datasets[1]).id != -1)
					item.y =  item.rows[1].value;

				if(datasets[2] && Dataset(datasets[2]).id != -1) {
					dataset = datasets[2] as Dataset;
					row = item.rows[2] as DataRow;
					if(Dataset(datasets[2]).time == 1) {
						item.radius = item.prevRadius = (row[year] - dataset.min) / (dataset.max - dataset.min) + maxRadius/100;
						item.radiusValue = row[year];
					}
					else {
						item.radius = item.prevRadius = (row.value - dataset.min) / (dataset.max - dataset.min) + maxRadius/100;
						item.radiusValue = row.value;
					}
				}
				else {
					item.radius = item.prevRadius = maxRadius;
					item.radiusValue = '';
				}
 				if(datasets[3] &&  Dataset(datasets[3]).time == 1 && Dataset(datasets[3]).id != -1) {
					dataset = datasets[3] as Dataset;
					row = item.rows[3] as DataRow;
					var value:String = row[year];
					item.color = dataset.colorArray[value];
					item.category = value;
				}
				if(categories.length > 0) {
					if(categories.indexOf(item.category) != -1)
						item.radius = item.prevRadius;
					else
						item.radius = 0;
				}
			}
		}
		
	}
}