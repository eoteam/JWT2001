package com.pentagram.instance.view.visualizer.renderers
{

	
	import com.greensock.TweenNano;
	import com.pentagram.model.vo.DataRow;
	
	import flare.util.Colors;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	


	internal class CircleRenderer extends UIComponent
	{
		
		

		private const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR;
		private const FILL_ALPHAS:Array = [0.8,0.8];
		private const FILL_RATIO:Array = [0,255];
		
		
	
		public function CircleRenderer() {		
			super();
		}
		protected var _radius:Number = 1;
		protected var _selected:Boolean = false;
		protected var _fixed:int = 0;
		protected var _fillColor:uint = 0xffcccccc;
		protected var _fillAlpha:Number = 0.7;
		protected var _lineColor:uint = 0xff000000;
		protected var _lineWidth:Number = 0;
		protected var _data:DataRow;
		
		// -- General Properties -------------------------------

		
		/** Flag indicating if this node is currently selected. This flag can
		 *  be used by renderers to display selection state. */
		public function get selected():Boolean { return _selected; }
		public function set selected(b:Boolean):void { if (b != _selected) {_selected = b;  } }	

		/** Object storing backing data values. */
		public function get data():DataRow { return _data; }
		public function set data(d:DataRow):void { _data = d; fillColor = d.country.region.color; }
		
		// -- Interaction Properties ---------------------------
		
		/** Fixed flag to prevent this sprite from being re-positioned. */
		public function get fixed():Boolean { return _fixed > 0; }
		/**
		 * Increments the fixed counter. If the fixed counter is greater than
		 * zero, the data sprite should be fixed. A counter is used so that if
		 * different components both adjust the fixed settings, they won't
		 * overwrite each other.
		 * @param num the amount to increment the counter by (default 1)
		 */
		public function fix(num:uint=1):void { _fixed += num; }
		/**
		 * Decrements the fixed counter. If the fixed counter is greater than
		 * zero, the data sprite should be fixed. A counter is used so that if
		 * different components both adjust the fixed settings, they won't
		 * overwrite each other. This method does not allow the fixed counter
		 * to go below zero.
		 * @param num the amount to decrement the counter by (default 1)
		 */
		public function unfix(num:uint=1):void { _fixed = Math.max(0, _fixed-num); }
		
		// -- Visual Properties --------------------------------
		/**
		 * The radius of the particle.
		 */
		public function get radius():Number { return _radius; }		
		/**
		 * @private
		 */
		public function set radius(r:Number):void {
			_radius = r;
			if(isNaN(_radius))
				_radius = 0;
			dirty();
		}
		
		/** The fill color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public function get fillColor():uint { return _fillColor; }
		public function set fillColor(c:uint):void { _fillColor = c; dirty();	}
		/** The alpha channel (a value between 0 and 1) for the fill color. */
		public function get fillAlpha():Number { return _fillAlpha; }//Colors.a(_fillColor) / 255; }
		public function set fillAlpha(a:Number):void {
			_fillAlpha = a;//Colors.setAlpha(_fillColor, uint(255*a)%256);
			dirty();
		}
		/** The hue component of the fill color in HSV color space. */
		public function get fillHue():Number { return Colors.hue(_fillColor); }
		public function set fillHue(h:Number):void {
			_fillColor = Colors.hsv(h, Colors.saturation(_fillColor),
				Colors.value(_fillColor), Colors.a(_fillColor)); 
			dirty();
		}
		/** The saturation component of the fill color in HSV color space. */
		public function get fillSaturation():Number { return Colors.saturation(_fillColor); }
		public function set fillSaturation(s:Number):void {
			_fillColor = Colors.hsv(Colors.hue(_fillColor), s,
				Colors.value(_fillColor), Colors.a(_fillColor));
			dirty();
		}
		/** The value (brightness) component of the fill color in HSV color space. */
		public function get fillValue():Number { return Colors.value(_fillColor); }
		public function set fillValue(v:Number):void {
			_fillColor = Colors.hsv(Colors.hue(_fillColor),
				Colors.saturation(_fillColor), v, Colors.a(_fillColor));
			dirty();
		}
		
		/** The line color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public function get lineColor():uint { return _lineColor; }
		public function set lineColor(c:uint):void { _lineColor = c; dirty(); }
		/** The alpha channel (a value between 0 and 1) for the line color. */
		public function get lineAlpha():Number { return Colors.a(_lineColor) / 255; }
		public function set lineAlpha(a:Number):void {
			_lineColor = Colors.setAlpha(_lineColor, uint(255*a)%256);
			dirty();
		}
		/** The hue component of the line color in HSV color space. */
		public function get lineHue():Number { return Colors.hue(_lineColor); }
		public function set lineHue(h:Number):void {
			_lineColor = Colors.hsv(h, Colors.saturation(_lineColor),
				Colors.value(_lineColor), Colors.a(_lineColor));
			dirty();
		}
		/** The saturation component of the line color in HSV color space. */
		public function get lineSaturation():Number { return Colors.saturation(_lineColor); }
		public function set lineSaturation(s:Number):void {
			_lineColor = Colors.hsv(Colors.hue(_lineColor), s,
				Colors.value(_lineColor), Colors.a(_lineColor));
			dirty();
		}
		/** The value (brightness) component of the line color in HSV color space. */
		public function get lineValue():Number { return Colors.value(_lineColor); }
		public function set lineValue(v:Number):void {
			_lineColor = Colors.hsv(Colors.hue(_lineColor),
				Colors.saturation(_lineColor), v, Colors.a(_lineColor));
			dirty();
		}

		
		// -- Methods ---------------------------------------------------------
		public function distanceToCenter(centerPoint:Point):Number
		{
			var dx:Number = x - centerPoint.x;
			var dy:Number = y - centerPoint.y;
			var distance:Number = dx*dx + dy*dy;
			
			return distance;
		}
		
		/** @inheritDoc */
		protected var dirtyFlag:Boolean = false;
		protected var dirtyCoordFlag:Boolean = false;
		protected var stateFlag:Boolean = false;
		public function dirty():void {
			dirtyFlag = true;
			this.invalidateDisplayList();
		}

		public function set state(value:Boolean):void {
			
			if(value && !stateFlag)
				dirtyFlag = true;
			stateFlag = value;
			this.invalidateDisplayList();
		}
		public function get state():Boolean {
			return stateFlag;
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(dirtyFlag && stateFlag)
				draw();
			else if(!stateFlag) {
				this.graphics.clear();
			}
		}
		protected function draw():void {
			dirtyFlag = false;
			graphics.clear();
			var matr:Matrix = new Matrix();
			matr.createGradientBox(_radius*2, _radius*2, Math.PI/1.7, 0, 0);
			graphics.lineStyle(_lineWidth,_lineColor,1);
			graphics.beginGradientFill(DEFAULT_GRADIENTTYPE,[fillColor,fillColor],[fillAlpha,fillAlpha],FILL_RATIO,matr)			
			graphics.drawCircle(0, 0, _radius);
			graphics.endFill();	
			if(this.alpha == 0) {
				TweenNano.to(this,0.5,{delay:1,alpha:1});
			}
		}
		public function dirtyCoordinates():void {
			dirtyCoordFlag = true;
			this.invalidateProperties();
		}
		override protected function commitProperties():void {
			super.commitProperties();
			if(dirtyCoordFlag)
				updateCoordinates();
		}
		protected function updateCoordinates():void {
			//throw exception
		}

	}
}