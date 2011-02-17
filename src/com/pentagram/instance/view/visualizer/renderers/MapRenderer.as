package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.utils.Colors;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.events.CloseEvent;
	import mx.events.ToolTipEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	
	import org.cove.ape.APEngine;
	import org.cove.ape.CircleParticle;
	
	import spark.components.Group;
	
	public class MapRenderer extends CircleParticle
	{
		public const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR
		public const FILL_ALPHAS:Array = [0.8,0.8];
		public const FILL_RATIO:Array = [0,255];
		public var countrySprite:Shape;
		public var id:String;
		protected var _content:String;
		
		private var label:TextField;
		private var textFormat:TextFormat;
		private var info:RendererInfo;
		private var tooltip:RendererToolTip;
		private var infoVisible:Boolean = false;
		
		protected var _data:DataRow;
		protected var tooltipContainer:Group;
		

		public function get data():DataRow { return _data; }
		public function set data(d:DataRow):void { _data = d;fillColor=d.country.region.color }	
		
		
		override public function set radius(r:Number):void {
			if(isNaN(r)) this.collidable = false;
			else this.collidable = true;
			super.radius = r;
		}
		
		
		public function MapRenderer(engine:APEngine,parent:Group,radius:Number=1, fixed:Boolean=false, mass:Number=1, elasticity:Number=0.3, friction:Number=0)
		{
			
			super(engine,0, 0, radius, fixed, mass, elasticity, friction);
			this.collidable = true;
			this.alwaysRepaint = true;
			this.tooltipContainer = parent;
			
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
			sprite.mouseChildren = false;
			sprite.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			sprite.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			sprite.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			sprite.addEventListener(MouseEvent.CLICK, mouseEventHandler);
			sprite.addEventListener(Event.REMOVED_FROM_STAGE,handleRemoved);
			
			//this.tooltip = tip;
			tooltip = new RendererToolTip();
			tooltipContainer.addElement(tooltip);
			tooltip.visible = false;
			
		}
		private function handleRemoved(event:Event):void {
			tooltipContainer.removeElement(tooltip);
		}
		public function draw():void {
			if(countrySprite) {
				var pt:Point = countrySprite.parent.localToGlobal(new Point(countrySprite.x,countrySprite.y));
				pt = sprite.parent.globalToLocal(pt);
				px = pt.x; py = pt.y;
				if(this.sprite) 
					sprite.x = pt.x; sprite.y = pt.y;
				redraw();
			}

		}
		protected function redraw():void {
			if(_visible) {
				var g:Graphics = this.sprite.graphics;
				g.clear();	
				var stroke:IStroke = new Stroke(fillColor,1,1);
				stroke.apply(g,null,null);
				var matr:Matrix = new Matrix();
				matr.createGradientBox(radius*2, radius*2, Math.PI/1.7, 0, 0);
				var colors:Array;
				label.visible = false;
				
				if(!isNaN(radius)) {
					if(_fillAlpha > 0.2) {
						colors = [_fillColor,Colors.darker(_fillColor)];
						textColor = 0xffffff;
					}
					else {
						colors =  [_fillColor,_fillColor];
						textColor = _fillColor;
					}
					g.beginGradientFill(DEFAULT_GRADIENTTYPE,colors,[_fillAlpha,_fillAlpha],FILL_RATIO,matr)			
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
				
					textFormat.color = _textColor;
					label.defaultTextFormat = textFormat;
					if(_data) {
						label.text = _data.country.shortname;
					}
									
					label.x = -label.textWidth/2;
					label.y = -label.textHeight/2;
					label.width = label.textWidth+4;
					label.height = label.textHeight+4;	
					label.defaultTextFormat = textFormat;
				}
			}
			
			if(sprite.visible != _visible) {
				if(_visible) {
					sprite.visible = true;
					TweenNano.to(sprite,0.5,{alpha:1});
				}	
				else
					TweenNano.to(sprite,0.1,{alpha:0,onComplete:hide});
			}
		}
		private var offset:int = 15;
		protected function mouseEventHandler(event:Event):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					var xPos:Number; var yPos:Number;
					if(sprite.alpha == 1) {
						if(sprite.parent.x + this.px + radius + tooltip.width + 10 > this.tooltipContainer.width) {
							tooltip.leftTip.visible = false;
							tooltip.rightTp.visible = true;
							xPos = sprite.parent.x + this.px - radius - tooltip.width - offset;
						}
						else { 
							tooltip.leftTip.visible = true;
							tooltip.rightTp.visible = false;
							xPos = sprite.parent.x + this.px + radius + offset;
						}
						yPos = this.py - tooltip.height/2;
						tooltip.visible = true;
						tooltip.content = _content;
						tooltip.country = data.country;
						tooltip.updatePosition(xPos,yPos);
						break;
					}
				}
					
				case MouseEvent.ROLL_OUT:
				{	
						if(sprite.alpha == 1) {
							tooltip.visible = false;
							break;
						}
				}
					
				case MouseEvent.MOUSE_DOWN:
				{
					break;
				}
					
				case MouseEvent.MOUSE_UP:
				{
					break;
				}
				case MouseEvent.CLICK:
				{
					if(!infoVisible && sprite.alpha == 1) {
						tooltip.visible = false;
						info = new RendererInfo();
						info.country = _data.country;
						info.content = _content;
						info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
						if(sprite.parent.x + this.px + radius + info.width + 10 > this.tooltipContainer.width) {
							info.leftTipVisible = false;
							info.rightTipVisible = true;
							info.x = sprite.parent.x + this.px - radius - info.width - offset;
						}
						else { 
							info.leftTipVisible = true;
							info.rightTipVisible = false;
							info.x = sprite.parent.x + this.px + radius + offset;
						}
						info.y = this.py+60;
						PopUpManager.addPopUp(info, this.tooltipContainer, false);
						infoVisible = true;
					}
				}
			}
		}
		private function handleInfoClose(event:CloseEvent):void {
			infoVisible = false;
		}
		override public function set visible(v:Boolean):void {
			_visible = v;
			this.collidable = v;
		}
		private function hide():void {
			sprite.visible = false;
		}
		public function set content(v:String):void {
			_content = v;
			if(this.infoVisible) {
				info.content = v;
			}
		}
		public function closeInfo():void {
			if(infoVisible) {
				infoVisible = false;
				this.info.close();
			}
		}
	}
}	