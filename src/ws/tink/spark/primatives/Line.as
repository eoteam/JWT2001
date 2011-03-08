/*

Copyright (c) 2010 Tink Ltd - http://www.tink.ws

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

package ws.tink.spark.primatives
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.utils.GraphicsUtil;
	
	import spark.primitives.Ellipse;
	import spark.primitives.Graphic;
	import spark.primitives.Rect;
	
	import ws.tink.graphics.Dash;
	import ws.tink.graphics.IGraphicsCreator;
	import ws.tink.graphics.utils.EllipseUtil;
	import ws.tink.graphics.utils.RectUtil;
	import ws.tink.spark.graphics.IGraphicsDefiner;
	
	public class Line extends spark.primitives.Line
	{
		
		private var _origin	: Point;
		
		public function Line()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		override protected function beginDraw(g:Graphics):void
		{
			_origin = new Point(drawX, drawY);
			
			// Don't call super.beginDraw() since it will also set up an 
			// invisible fill.
			if( stroke )
			{
				if( stroke is IGraphicsDefiner )
				{
					g.lineStyle();
				}
				else
				{
					setupStroke( g );
				}
			}
			else
			{
				g.lineStyle();
			}
		}
		
		
		private function setupStroke( g:Graphics ):void
		{
			g.endFill();
			
			var strokeBounds:Rectangle = getStrokeBounds();
			strokeBounds.offset(drawX, drawY);
			stroke.apply( g, strokeBounds, _origin );
		}
		
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function draw(g:Graphics):void
		{
			var strokeCreator:IGraphicsCreator = ( stroke is IGraphicsDefiner ) ? IGraphicsDefiner( stroke ).graphicsCreator : null;
			
			if( !strokeCreator )
			{
				return super.draw( g );
			}
			else
			{
				setupStroke( g );
				
				// Our bounding box is (x1, y1, x2, y2)
				var x1:Number = measuredX + drawX;
				var y1:Number = measuredY + drawY;
				var x2:Number = measuredX + drawX + width;
				var y2:Number = measuredY + drawY + height;    
				
				// Which way should we draw the line?
				if ((xFrom <= xTo) == (yFrom <= yTo))
				{ 
					// top-left to bottom-right
					strokeCreator.moveTo(x1, y1);
					strokeCreator.lineTo(x2, y2);
				}
				else
				{
					// bottom-left to top-right
					strokeCreator.moveTo(x1, y2);
					strokeCreator.lineTo(x2, y1);
				}
			}
		}
	}
}