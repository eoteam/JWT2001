package com.pentagram.instance.view.visualizer.renderers
{
	import com.pentagram.utils.Colors;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	
	import org.cove.ape.CircleParticle;
	
	public class PhysicsParticle extends CircleParticle
	{
		public const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR
		public const FILL_ALPHAS:Array = [0.8,0.8];
		public const FILL_RATIO:Array = [0,255];
		protected var label:TextField;
		protected var textFormat:TextFormat;
		
		public function PhysicsParticle(x:Number, y:Number, radius:Number, fixed:Boolean=false, mass:Number=1, elasticity:Number=0.3, friction:Number=0)
		{
			super(x, y, radius, fixed, mass, elasticity, friction);
			this.collidable = true;
			this.alwaysRepaint = true;
	
			textFormat = new TextFormat();
			textFormat.font = "FlamaBookMx2";
			textFormat.size = 12;
			textFormat.color = 0xff0000;
			textFormat.align="left";
			
			label = new TextField();
			label.selectable = false;
			label.embedFonts = true;
			label.mouseEnabled = false;
			label.defaultTextFormat = textFormat;
			label.width = 30; label.height = 20;	
			sprite.addChild(label);
			
		}
		override public function redraw():void {
			var g:Graphics = this.sprite.graphics;
			g.clear();	
			var stroke:IStroke = new Stroke(fillColor,1,1);
			stroke.apply(g,null,null);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(radius*2, radius*2, Math.PI/1.7, 0, 0);
			var colors:Array;
			if(fillAlpha > 0.2)
				colors = [fillColor,Colors.darker(fillColor)];
			else
				colors =  [fillColor,fillColor];
			g.beginGradientFill(DEFAULT_GRADIENTTYPE,colors,[fillAlpha,fillAlpha],FILL_RATIO,matr)			
			g.drawCircle(0, 0, radius);
			g.endFill(); 
			
			if(radius < 30 && radius > 15)  {
				textFormat.size = 10;
				label.visible = true;
			}
			else if(radius <= 15)
				label.visible = false;
			else {
				textFormat.size = 12;
				label.visible = true;	
			}
			textFormat.color = 0xffffff;			
			label.text = "USA";
			label.x = -label.textWidth/2;
			label.y = -label.textHeight/2;
			label.width = label.textWidth+4;
			label.height = label.textHeight+4;	
			label.defaultTextFormat = textFormat;
		}
	}
}	