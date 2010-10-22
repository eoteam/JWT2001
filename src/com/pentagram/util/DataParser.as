package com.pentagram.util
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataCell;
	import com.pentagram.model.vo.DataColumn;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;

	public class DataParser
	{

		public static function parseData(data:Array,dataset:Dataset,client:Client):void {
			var prop:String;
			var item:Object;
			var row:DataRow;
			var rowCell:DataCell;
			var colCell:DataCell;
			
			for each(var country:Country in client.countries.source) {
				for each(item in data) {
					if(item.countryid == country.id.toString()) {
						row = new DataRow();
						row.name = country.name;	
						row.id = Number(item.id);
						for(prop in item) { 
							if(prop != 'id' && prop != 'countryid') {
								//var point:DataCell = new DataCell();
								//point.key = Number(prop);
								//point.value = dataset.type == 1 ? Number(item[prop]) : item[prop]; 
								row.points[prop] = dataset.type == 1 ? Number(item[prop]) : item[prop]; 
							}
						}
						dataset.rows.addItem(row);
						break;
					}
				}
			}
				
//			if(dataset.time == 1) {
//				for (var i:int=dataset.years[0];i<=dataset.years[1];i++) {
//					var col:DataColumn = new DataColumn();
//					col.year = i;
//					dataset.columns.addItem(col);
//				}
//				
//				for each(item in data) {
//					row = new DataRow();
//					row.id = item.id;
//					row.countryid = item.countryid;
//					dataset.rows.addItem(row);
//					for(prop in item) {
//						if(prop != 'id' && prop != 'countryid') {
//							rowCell = new DataCell();
//							rowCell.key = Number(prop);
//							rowCell.value = dataset.type == 1 ? Number(item[prop]) : item[prop]; 
//							row.points.push(rowCell);
//
//							colCell = new DataCell();
//							colCell.key = item.countryid;
//							colCell.value = dataset.type == 1 ? Number(item[prop]) : item[prop];
//							DataColumn(dataset.columns.getItemAt(Number(prop) - dataset.years[0])).points.push(colCell);
//						}
//					}
//				}
//			}
//			else {
//				row = new DataRow();
//				dataset.rows.addItem(row);
//			}
		}
		public static function getCountryById(client:Client,countryid:int):Country {
			var res:Country;
			for each(var country:Country in client.countries.source) {
				if(country.id == countryid) {
					res = country;
					break;
				}
			}
			return res;
		}
	}
}