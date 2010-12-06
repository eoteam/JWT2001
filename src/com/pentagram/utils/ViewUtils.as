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
	}
}