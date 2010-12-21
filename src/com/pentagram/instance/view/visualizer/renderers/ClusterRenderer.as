package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.model.vo.DataRow;
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class ClusterRenderer extends CircleRenderer
	{
		public function ClusterRenderer()
		{
			super();
			this.fillAlpha = 1;
			
		}
		public var radiusBeforeRendering:Number;
		public var data2:DataRow;
//		override protected function draw():void {
//			dirtyFlag = false;
//			graphics.clear(); 
//			var matr:Matrix = new Matrix();
//			matr.createGradientBox(_radius*2, _radius*2, Math.PI/1.7, 0, 0);
//			graphics.lineStyle(_lineWidth,_lineColor,1);
//			graphics.beginGradientFill(DEFAULT_GRADIENTTYPE,[fillColor,fillColor],[fillAlpha,fillAlpha],FILL_RATIO,matr)			
//			graphics.drawRect(0, 0, _radius,_radius);
//			graphics.endFill();	
//			if(this.alpha == 0) {
//				TweenNano.to(this,0.5,{delay:1,alpha:1});
//			}
//		}		
	}
	
}