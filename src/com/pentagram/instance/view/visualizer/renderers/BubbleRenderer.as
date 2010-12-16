////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.pentagram.instance.view.visualizer.renderers
{
	
	import com.greensock.TweenNano;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.charts.ChartItem;
	import mx.charts.chartClasses.GraphicsUtilities;
	import mx.core.IDataRenderer;
	import mx.graphics.IFill;
	import mx.graphics.IStroke;
	import mx.graphics.SolidColor;
	import mx.skins.ProgrammaticSkin;
	import mx.utils.ColorUtil;
	
	/**
	 *  A simple chart itemRenderer implementation
	 *  that fills an elliptical area.
	 *  This class can be used as an itemRenderer for ColumnSeries, BarSeries, AreaSeries, LineSeries,
	 *  PlotSeries, and BubbleSeries objects.
	 *  It renders its area on screen using the <code>fill</code> and <code>stroke</code> styles
	 *  of its associated series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class BubbleRenderer extends ProgrammaticSkin
		implements IDataRenderer
	{
		//include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static var rcFill:Rectangle = new Rectangle();
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function BubbleRenderer() 
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  data
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the data property.
		 */
		private var _data:Object;
		
		[Inspectable(environment="none")]
		
		/**
		 *  The chartItem that this itemRenderer displays.
		 *  This value is assigned by the owning series.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 *  @private
		 */
		private var prevW:Number;
		private var prevH:Number;
		public function set data(value:Object):void
		{
			if (_data == value) { 
				return;
//				if(!_data.item.visible && this.alpha == 1) {
//					prevW = width; prevH=height;
//					TweenNano.to(this,.5,{width:0,height:0,onComplete:adjust,onUpdate:invalidateDisplayList});
//				}
//				else if(_data.item.visible && this.alpha == 0)
//					TweenNano.to(this,.5,{alpha:1});
			}
			_data = value;
		}
		private function adjust():void {
			alpha = 0;
			width = prevW; height= prevH;
		}
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			draw(unscaledWidth, unscaledHeight);
		}
		private function draw(unscaledWidth:Number,unscaledHeight:Number):void {
			var fill:IFill;
			var state:String = "";
			
			if (_data is ChartItem && _data.hasOwnProperty('fill'))
			{
				fill = _data.fill;
				state = _data.currentState;
			}
			else
				fill = GraphicsUtilities.fillFromStyle(getStyle('fill'));
			
			
			var color:uint = data.item.color;
			var alpha:Number = data.item.alpha;
			var adjustedRadius:Number = 0;
			
			switch (state)
			{
				case ChartItem.FOCUSED:
				case ChartItem.ROLLOVER:
					color = ColorUtil.adjustBrightness2(color,-20);
					fill = new SolidColor(color,alpha);
					adjustedRadius = getStyle('adjustedRadius');
					if (!adjustedRadius)
						adjustedRadius = 0;
					break;
				case ChartItem.DISABLED:
					color = ColorUtil.adjustBrightness2(color,20);
					fill = new SolidColor(color,alpha);
					break;
				case ChartItem.FOCUSEDSELECTED:
				case ChartItem.SELECTED:
					color = ColorUtil.adjustBrightness2(color,-30);
					fill = new SolidColor(color,alpha);
					adjustedRadius = getStyle('adjustedRadius');
					if (!adjustedRadius)
						adjustedRadius = 0;
					break;
				default:
					fill = new SolidColor(color,alpha);
					break;
			}
			//fill = new SolidColor(color,data.item.alpha);
			var stroke:IStroke = getStyle("stroke");
			
			var w:Number = stroke ? stroke.weight / 2 : 0;
			
			rcFill.right = unscaledWidth;
			rcFill.bottom = unscaledHeight;
			
			var g:Graphics = graphics;
			g.clear();		
			if (stroke)
				stroke.apply(g,null,null);
			if (fill)
				fill.begin(g, rcFill, null);
			g.drawEllipse(w - adjustedRadius,w - adjustedRadius,unscaledWidth - 2 * w + adjustedRadius * 2, unscaledHeight - 2 * w + adjustedRadius * 2);
			
			if (fill)
				fill.end(g);
		}
	}
	
}
