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
	
	import com.pentagram.model.vo.NormalizedVO;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.charts.ChartItem;
	import mx.charts.chartClasses.GraphicsUtilities;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.graphics.IFill;
	import mx.graphics.IStroke;
	import mx.graphics.SolidColor;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	import mx.skins.ProgrammaticSkin;
	import mx.utils.ColorUtil;
	

	public class BubbleRenderer extends UIComponent implements IDataRenderer
	{


		private static var rcFill:Rectangle = new Rectangle();
		private var info:RendererInfo;
		private var infoVisible:Boolean = false;
		private var radius:Number = 0;
		private var actualX:Number;
		private var actualY:Number;
		
		private var offset:int = 15;
		
		public function BubbleRenderer() 
		{
			super();
			textFormat = new TextFormat();
			textFormat.font = "FlamaBookMx2";
			textFormat.size = 12;
			textFormat.align="left";
			
			label = new TextField();
			label.selectable = false;
			
			label.embedFonts = true;
			label.mouseEnabled = false;
			label.defaultTextFormat = textFormat;
			this.addChild(label);
			this.addEventListener(MouseEvent.CLICK,mouseEventHandler);

		}


		private var _data:Object;
		
		[Inspectable(environment="none")]
		

		public function get data():Object
		{
			return _data;
		}
		protected var label:TextField;
		protected var textFormat:TextFormat;
		protected var item:NormalizedVO;
		
		public function set data(value:Object):void
		{
			if (_data == value) { 
				return;
			}
			_data = value;
			item = value.item as NormalizedVO;
		}		
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
			
			
			var color:uint = _data.item.color;
			var alpha:Number = 0.2;//data.item.alpha;
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
			Stroke(stroke).color = color;
			Stroke(stroke).alpha = 1;
			var w:Number = stroke ? stroke.weight / 2 : 0;
			
			rcFill.right = unscaledWidth;
			rcFill.bottom = unscaledHeight;
			
			var g:Graphics = graphics;
			g.clear();		
			if (stroke)
				stroke.apply(g,null,null);
			if (fill)
				fill.begin(g, rcFill, null);
			radius = unscaledWidth - 2 * w + adjustedRadius * 2;
			actualX = w - adjustedRadius;
			g.drawEllipse(w - adjustedRadius,
						  w - adjustedRadius,
						  unscaledWidth - 2 * w + adjustedRadius * 2,
						  unscaledHeight - 2 * w + adjustedRadius * 2);
			
			if (fill)
				fill.end(g);
	
			
				textFormat.color = color;
				label.x = (unscaledWidth - 2 * w + adjustedRadius * 2)/2 - label.textWidth/2;
				label.y = (unscaledHeight - 2 * w + adjustedRadius * 2)/2 - label.textHeight/2;
				label.defaultTextFormat = textFormat;
				label.text = _data.item.shortname;
				
			if(unscaledWidth - 2 * w + adjustedRadius * 2 > 0) {	
				this.visible = true;
			}
			else
				this.visible = false;
		}
		protected function mouseEventHandler(event:MouseEvent):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			
			if(!infoVisible) {
				info = new RendererInfo();
				info.country = item.country;
				//info.content = _content;
				info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				if(actualX  + radius + info.width + 10 > this.parentDocument.width) {
					info.leftTipVisible = false;
					info.rightTipVisible = true;
					info.x = x + actualX - radius*2 - info.width - offset;
				}
				else { 
					info.leftTipVisible = true;
					info.rightTipVisible = false;
					info.x = x + actualX + radius + offset;
				}
				info.y = y+actualX+radius+info.height/2;
				PopUpManager.addPopUp(info, this.parentDocument as UIComponent, false);
				infoVisible = true;
			}
		}
		private function handleInfoClose(event:CloseEvent):void {
			infoVisible = false;
		}
	}
}
