package com.pentagram.utils
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataCell;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayList;
	
	public class ViewUtils
	{


		public static function instantiateClass(className:String):*
		{
			var instance:*;
			
			try
			{
				instance = getDefinitionByName(className);
			}
			catch (e:Error)
			{
				throw new Error("Could not find class for className: " + className);
			}
			
			return new instance();
		}  
		public static function executeLater(fc:Function,args:Array=null,time:int=1000):CallTimer {
			var timer:CallTimer = new CallTimer(fc,args,time);
			timer.start();
			return timer;
		}
		public static function vectorToArray(v:*):Array {
			var arr:Array = new Array();
			for each (var elem:* in v) {
				    arr.push(elem);
			}
			return arr;
		}
		public static function map(value:Number,istart:Number, istop:Number,ostart:Number,ostop:Number):Number {
			return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
		}    
//		public static function normalizeValue(dataset:Dataset,index:int,year:int=0):Number {
//			if(dataset.type == 1) {
//				var row:DataRow = dataset.rows.getItemAt(index) as DataRow;
//				var value:Number;
//				value = dataset.t
//			}
//			else return 0;
//		}
	}
}