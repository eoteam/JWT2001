package com.pentagram.utils
{
	import com.pentagram.model.vo.Client;
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.DataCell;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.model.vo.Dataset;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import mx.collections.ArrayList;
	
	public class ViewUtils
	{
		public static function instantiateClass(className:String):* {
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
		public static function newSibling(sourceObj:Object):* {
			if(sourceObj) {
				
				var objSibling:*;
				try {
					var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
					objSibling = new classOfSourceObj();
				}
				
				catch(e:Object) {}
				
				return objSibling;
			}
			return null;
		}
		
		public static function clone(source:Object):Object {
			
			var clone:Object;
			if(source) {
				clone = newSibling(source);
				
				if(clone) {
					copyData(source, clone);
				}
			}
			
			return clone;
		}
		
		public static function copyData(source:Object, destination:Object):void {
			
			//copies data from commonly named properties and getter/setter pairs
			if((source) && (destination)) {
				
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					
					for each(prop in sourceInfo.variable) {
						
						if(destination.hasOwnProperty(prop.@name)) {
							destination[prop.@name] = source[prop.@name];
						}
						
					}
					
					for each(prop in sourceInfo.accessor) {
						if(prop.@access == "readwrite") {
							if(destination.hasOwnProperty(prop.@name)) {
								destination[prop.@name] = source[prop.@name];
							}
							
						}
					}
				}
				catch (err:Object) {
					;
				}
			}
		}
	}
}