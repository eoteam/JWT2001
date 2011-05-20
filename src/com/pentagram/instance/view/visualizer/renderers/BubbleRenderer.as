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
	
	import com.pentagram.instance.view.visualizer.interfaces.IRenderer;
	import com.pentagram.model.vo.NormalizedVO;
	import com.pentagram.utils.Colors;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
	

	public class BubbleRenderer extends UIComponent implements IRenderer
	{

		private static var rcFill:Rectangle = new Rectangle();
		private var info:RendererInfo;
		private var _infoVisible:Boolean = false;
		private var radius:Number = 0;
		private var _data:Object;
		
		private var offset:int = 15;

		protected var label:TextField;
		protected var textFormat:TextFormat;
		protected var item:NormalizedVO;
		protected var dirtyTooltipFlag:Boolean = false;
		
		public const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR;
		public const FILL_ALPHAS:Array = [0.8,0.8];
		public const FILL_RATIO:Array = [0,255];
		
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
			//this.addEventListener(MouseEvent.CLICK,mouseEventHandler);
		}

	
		[Inspectable(environment="none")]
		
		public function get data():Object
		{
			return _data;
		}

		
		public function set data(value:Object):void
		{
			if (_data == value) { 
				return;
			}
			_data = value;
			item = value.item as NormalizedVO;
			if(infoVisible && item.country == info.country && item.content != null && info.content != item.content)
				info.content = item.content;
//			else if(infoVisible && item.country != info.country) {
//				info.country = item.country;
//				info.content = item.content;
//				moveInfo();
//			}
		}		
		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			draw2(unscaledWidth, unscaledHeight);
		}
		private function draw2(unscaledWidth:Number,unscaledHeight:Number):void {
			var state:String = "";
			var colors:Array;
			var color:uint = _data.item.color;
			var alpha:Number = _data.item.alpha;
			var adjustedRadius:Number = 0;
			
			if(alpha > 0.2)
				colors = [color,Colors.darker(color)];
			else
				colors =  [color,color];
			
			switch (state)
			{
				case ChartItem.FOCUSED:
				case ChartItem.ROLLOVER:
					adjustedRadius = getStyle('adjustedRadius');
					if (!adjustedRadius)
						adjustedRadius = 0;
					break;
				case ChartItem.DISABLED:
					break;
				case ChartItem.FOCUSEDSELECTED:
				case ChartItem.SELECTED:
					adjustedRadius = getStyle('adjustedRadius');
					if (!adjustedRadius)
						adjustedRadius = 0;
					break;
				default:
				break;
			}
			var stroke:IStroke = getStyle("stroke");
			Stroke(stroke).color = color;
			Stroke(stroke).alpha = 1;
			var w:Number = stroke ? stroke.weight / 2 : 0;
			
			rcFill.right = unscaledWidth;
			rcFill.bottom = unscaledHeight;
			
			var rW:Number = unscaledWidth - 2 * w + adjustedRadius * 2;
			var rH:Number = unscaledHeight - 2 * w + adjustedRadius * 2;
			radius = rH;
			var matr:Matrix = new Matrix();
			matr.createGradientBox(rW*2,rH*2, Math.PI/1.7, 0, 0);
			
			rcFill.right = unscaledWidth;
			rcFill.bottom = unscaledHeight;
			
			var g:Graphics = graphics;
			g.clear();		
			if (stroke)
				stroke.apply(g,null,null);
			
			g.beginGradientFill(DEFAULT_GRADIENTTYPE,colors,[alpha,alpha],FILL_RATIO,matr);
			g.drawEllipse(w - adjustedRadius, w - adjustedRadius,rW,rH);
			g.endFill();	
				
			textFormat.color = alpha>0.4?0xffffff:color;
			textFormat.size = 14;
			label.width = rW - 4 > 0 ? rW-4:0;
			label.height = label.textHeight + 4;
			label.visible = label.width >= 10 ? true:false;
			trace(label.width);
			//scaleTextFieldToFitText(rW)
			//scaleTextToFitInTextField();
						
			label.x = (unscaledWidth - 2 * w + adjustedRadius * 2)/2 - label.textWidth/2;
			label.y = (unscaledHeight - 2 * w + adjustedRadius * 2)/2 - label.textHeight/2;
			label.defaultTextFormat = textFormat;
			label.text = _data.item.shortname;
			
			if(unscaledWidth - 2 * w + adjustedRadius * 2 > 0)	
				this.visible = true;
			else
				this.visible = false;
			
		}
		public function draw():void { 
			
		}
		public function toggleTooltip(visible:Boolean):void {
			
		}
		
		private function handleInfoClose(event:CloseEvent):void {
			infoVisible = false;
		}
		override public function move(x:Number, y:Number):void {
			super.move(x,y);
			if(infoVisible && item.country == info.country && info.pinned) {
				dirtyTooltipFlag = true;
				this.invalidateProperties();
			}
		}
		public function set content(value:String):void {
			
		}
		override protected function commitProperties():void {
			super.commitProperties();
			if(dirtyTooltipFlag) {
				dirtyTooltipFlag = false;
				moveInfo();
			}
		}
		
		public function toggleInfo(visible:Boolean):void {
			if(!visible && infoVisible) {
				this.info.close();
			}
			else if(visible && !infoVisible && _data) {
				info = new RendererInfo();
				info.data = item.country;
				info.content = item.content;
				info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				moveInfo();
				PopUpManager.addPopUp(info, this.parentDocument as UIComponent, false);
			}	
			infoVisible = visible;
		}	
		public function moveInfo():void {
			var pt:Point = this.parent.localToGlobal(new Point(x,y));
			if( pt.x + info.width + width + offset > this.parentDocument.width) {
				info.leftTipVisible = false;
				info.rightTipVisible = true;
				info.x =  pt.x - info.width - offset;
			}
			else { 
				info.leftTipVisible = true;
				info.rightTipVisible = false;
				info.x = pt.x+width+offset;
			}
			info.y = pt.y+radius/2-info.height/2-4;
		}
		private function set infoVisible(value:Boolean):void {
			_infoVisible = value;
		}
		private function get infoVisible():Boolean {
			return _infoVisible;
		}
//		protected function scaleTextToFitInTextField():void
//		{  		
//			textFormat.size = label.width;
//			label.setTextFormat( textFormat );			
//			var ranThrough:Boolean = false;
//			while ( label.textWidth > label.width - 4) 
//			{    
//				textFormat.size = int( textFormat.size ) - 1;    
//				label.setTextFormat( textFormat );  
//				if(textFormat.size < 8) 
//					break;
//			}
//			label.setTextFormat( textFormat );  
//			label.visible = textFormat.size>=8?true:false;
//		}
//		
//		protected function scaleTextFieldToFitText(r:Number) : void
//		{
//			//the 4s take into account Flash's default padding.
//			//If I omit them, edges of character get cut off.
//			label.width = r - 4>0 ? r-4:0;
//			label.height = label.textHeight + 4;
//		}
	}
}
