package com.pentagram.instance.view.visualizer.renderers
{
	import com.pentagram.instance.model.vo.Point3D;
	import com.pentagram.instance.view.visualizer.interfaces.IRenderer;
	import com.pentagram.instance.view.visualizer.interfaces.IRendererInfo;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.utils.Colors;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.SpriteVisualElement;
	

	internal class BaseRenderer extends Sprite implements IRenderer
	{

		protected var labelTF:TextField;
		protected var textFormat:TextFormat;
		protected var _selected:Boolean = false;
		protected var _fixed:int = 0;
		protected var _fillColor:uint = 0xffcccccc;
		protected var _textColor:uint = 0xffffff;
		protected var _fillAlpha:Number = 0.2;
		protected var _lineColor:uint = 0xff000000;
		protected var _lineWidth:Number = 0;
		[Bindable] protected var _radius:Number = 1;
	
		//protected var dirtyFlag:Boolean = false;
		//protected var dirtyTooltipFlag:Boolean = false;
		//protected var stateFlag:Boolean = false;
		protected var infoVisible:Boolean = false;
		protected var offset:int = 15;
		
		protected var tooltipContainer:Group;
		protected var directParent:DisplayObject;
		protected var tooltip:Group;
		protected var info:IRendererInfo;
		
		public const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR;
		public const FILL_ALPHAS:Array = [0.8,0.8];
		public const FILL_RATIO:Array = [0,255];
		
		public var point:Point3D;
		
		protected var _content:String;
		protected var _data:Object;
		
		public var radiusBeforeRendering:Number;
		
		public function get data():Object { return _data; }
		public function set data(d:Object):void { 
			_data = d; 
		}	
		public function BaseRenderer(parent:Group,parent2:DisplayObject):void {
			this.mouseChildren = false;
			this.textColor = 0xffffffff;
			this.tooltipContainer = parent;
			this.directParent = parent2;
			
			textFormat = new TextFormat();
			textFormat.font = "FlamaBookMx2";
			textFormat.size = 12;
			textFormat.color = _textColor;
			textFormat.align="left";
			
			labelTF = new TextField();
			labelTF.selectable = false;
			labelTF.embedFonts = true;
			labelTF.mouseEnabled = false;
			labelTF.defaultTextFormat = textFormat;
			labelTF.width = 30; labelTF.height = 20;	
			labelTF.rotationY = 180;
			this.addChild(labelTF);
			
			this.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			this.addEventListener(MouseEvent.CLICK, mouseEventHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE,handleRemoved);
			
		}
		public function get fixed():Boolean { return _fixed > 0; }
		public function fix(num:uint=1):void { _fixed += num; } 
		public function unfix(num:uint=1):void { _fixed = Math.max(0, _fixed-num); }
			
			
		[Bindable] public function get radius():Number { return _radius; }		
		public function set radius(r:Number):void {
			 _radius = r;
			if(isNaN(_radius))
				_radius = 0;
			if(_radius == 0)
				visible = false;
			else
				visible = true;
			
		}		
		public function get fillColor():uint { return _fillColor; }
		public function set fillColor(c:uint):void { _fillColor = c; }
		
		public function get textColor():uint { return _textColor; }
		public function set textColor(c:uint):void { _textColor = c; }
		
		public function get fillAlpha():Number { return _fillAlpha; }//Colors.a(_fillColor) / 255; }
		public function set fillAlpha(a:Number):void {
			_fillAlpha = a;//Colors.setAlpha(_fillColor, uint(255*a)%256);
			
		}	
		
		public function get fillHue():Number { return Colors.hue(_fillColor); }
		public function set fillHue(h:Number):void {
			_fillColor = Colors.hsv(h, Colors.saturation(_fillColor),
				Colors.value(_fillColor), Colors.a(_fillColor)); 
			
		}
		
		public function get fillSaturation():Number { return Colors.saturation(_fillColor); }
		public function set fillSaturation(s:Number):void {
			_fillColor = Colors.hsv(Colors.hue(_fillColor), s,
				Colors.value(_fillColor), Colors.a(_fillColor));
			
		}
		
		public function get fillValue():Number { return Colors.value(_fillColor); }
		public function set fillValue(v:Number):void {
			_fillColor = Colors.hsv(Colors.hue(_fillColor),
				Colors.saturation(_fillColor), v, Colors.a(_fillColor));
			
		}
		
		public function get lineColor():uint { return _lineColor; }
		public function set lineColor(c:uint):void { _lineColor = c;  }
		
		public function get lineAlpha():Number { return Colors.a(_lineColor) / 255; }
		public function set lineAlpha(a:Number):void {
			_lineColor = Colors.setAlpha(_lineColor, uint(255*a)%256);
			
		}
		
		public function get lineHue():Number { return Colors.hue(_lineColor); }
		public function set lineHue(h:Number):void {
			_lineColor = Colors.hsv(h, Colors.saturation(_lineColor),
				Colors.value(_lineColor), Colors.a(_lineColor));
			
		}
		
		public function get lineSaturation():Number { return Colors.saturation(_lineColor); }
		public function set lineSaturation(s:Number):void {
			_lineColor = Colors.hsv(Colors.hue(_lineColor), s,
				Colors.value(_lineColor), Colors.a(_lineColor));
			
		}
		
		public function get lineValue():Number { return Colors.value(_lineColor); }
		public function set lineValue(v:Number):void {
			_lineColor = Colors.hsv(Colors.hue(_lineColor),
				Colors.saturation(_lineColor), v, Colors.a(_lineColor));
			
		}

		
		// -- Methods ---------------------------------------------------------
		public function distanceToCenter(centerPoint:Point):Number
		{
			var dx:Number = x - centerPoint.x;
			var dy:Number = y - centerPoint.y;
			var distance:Number = dx*dx + dy*dy;
			
			return distance;
		}
		
		
//		private function dirty():void {
//			dirtyFlag = true;
//			this.updateDisplayList();
//		}
		override public function set x(value:Number):void {
			super.x = value;
			if(infoVisible) {
				moveInfo();
//				dirtyTooltipFlag = true;
//				this.commitProperties();
			}
		}
		override public function set y(value:Number):void {
			super.y = value;
			if(infoVisible) {
				moveInfo();
//				dirtyTooltipFlag = true;
//				this.commitProperties();
			}
		}
//		protected function updateDisplayList():void {
//			
//		}
//		protected function commitProperties():void {
//			//super.commitProperties();
//			if(dirtyTooltipFlag) {
//				dirtyTooltipFlag = false;
//				moveInfo();
//			}
//		}
		public function moveInfo():void {
			
		}
		protected function mouseEventHandler(event:Event):void {
			
		}
		private function handleRemoved(event:Event):void {
			if(tooltipContainer.contains(tooltip))
				tooltipContainer.removeElement(tooltip);
			if(infoVisible)
				info.close();
		}
		public function draw():void {
			var g:Graphics = this.graphics;
			//dirtyFlag = false;
			g.clear();
			var stroke:IStroke = new Stroke(_fillColor,1,1);
			stroke.apply(g,null,null);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(_radius*2, _radius*2, Math.PI/1.7, 0, 0);
			var colors:Array;
			if(_fillAlpha > 0.2) {
				colors = [_fillColor,Colors.darker(_fillColor)];
				//_textColor = _fillColor;
			}
			else {
				colors =  [_fillColor,_fillColor];
				//_textColor = 0xffffff;
			}
			g.beginGradientFill(DEFAULT_GRADIENTTYPE,colors,[_fillAlpha,_fillAlpha],FILL_RATIO,matr)			
			g.drawCircle(0, 0, _radius);
			g.endFill();	
			
			
			labelTF.width = labelTF.textWidth;
			
			if(_radius < labelTF.textWidth && _radius > labelTF.textWidth/2)  {
				textFormat.size = 10;
				labelTF.visible = true;
			}
			else if(_radius <= labelTF.textWidth/2)
				labelTF.visible = false;
			else {
				textFormat.size = 12;
				labelTF.visible = true;	
			}
			textFormat.color = _textColor;			
			if(labelTF.rotationY == 0)
				labelTF.x = -labelTF.textWidth/2;
			else
				labelTF.x = labelTF.textWidth/2;
			labelTF.y = -labelTF.textHeight/2;
			labelTF.width = labelTF.textWidth+4;
			labelTF.height = labelTF.textHeight+4;	
			labelTF.defaultTextFormat = textFormat;
			
			if(this.alpha == 0) {
				alpha = 1;visible = true;
			}
		}
		public function set content(value:String):void {
			_content = value;
		}
		public function toggleInfo(visible:Boolean):void {
			
		}
	}
}