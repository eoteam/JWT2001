package com.pentagram.view.controls
{
	import mx.skins.ProgrammaticSkin;
	
	import spark.components.Group;
	import spark.components.supportClasses.Skin;
	import spark.core.SpriteVisualElement;
	
	public class DottedGrid extends Skin
	{
		public function DottedGrid()
		{
			super();
		}
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w,h);
			drawGrid();
		}  
		protected function drawGrid():void {
			var numW:int = Math.ceil(width/20);
			var numH:int = Math.floor(height/20)-1;
			this.graphics.clear();
			this.graphics.beginFill(0xB3B1AC);
			for (var i:int=0;i<=numW;i++) {
				for (var j:int=0;j<=numH;j++) {
					this.graphics.moveTo(i*20+5,j*20+5);
					this.graphics.drawCircle(i*20+5,j*20+5,1);
				}
			}
			this.graphics.endFill();
		}
	}
}