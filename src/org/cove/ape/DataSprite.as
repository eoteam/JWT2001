package org.cove.ape
{

	import com.pentagram.model.vo.DataRow;
	
	import flash.display.Sprite;
	
	import mx.core.UIComponent;
		
	public class DataSprite extends UIComponent
	{
		protected var _data:DataRow;
		
		public function get data():DataRow { return _data; }
		public function set data(d:DataRow):void { 
			_data = d; 
		}
		public function DataSprite()
		{
			super();
		}

	}
}