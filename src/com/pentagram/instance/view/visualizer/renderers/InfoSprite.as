package com.pentagram.instance.view.visualizer.renderers
{
	import com.pentagram.model.vo.DataRow;
	
	import flash.display.Sprite;
	
	public class InfoSprite extends Sprite
	{
		public function InfoSprite()
		{
			super();
		}
		public var data:DataRow;
		public var radius:Number;
		public function drawCircle(z:Number):void {
			this.graphics.clear();
			this.graphics.beginFill(0xff0000,1);
			this.graphics.drawCircle(0,0,z);
			this.graphics.endFill();
			this.graphics.beginFill(0,1);
			this.graphics.drawCircle(0,0,0.5);
			this.graphics.endFill();
		}
	}
}