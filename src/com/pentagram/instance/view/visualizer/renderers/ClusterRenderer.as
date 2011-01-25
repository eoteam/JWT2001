package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.utils.Colors;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.events.CloseEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.core.SpriteVisualElement;

	public class ClusterRenderer extends BaseRenderer
	{
		public var radiusBeforeRendering:Number;
		public var data2:DataRow;
		
		 
		private var info:RendererInfo;
		private var infoVisible:Boolean = false;
		private var tooltip:RendererToolTip;
		
		public const DEFAULT_GRADIENTTYPE:String = GradientType.LINEAR;
		public const FILL_ALPHAS:Array = [0.8,0.8];
		public const FILL_RATIO:Array = [0,255];
		
		protected var tooltipContainer:Group;
		protected var directParent:SpriteVisualElement;
		protected var stateFlag:Boolean = false;
		protected var dirtyFlag:Boolean = false;
		protected var dirtyCoordFlag:Boolean = false;
		
		public function ClusterRenderer(parent:Group,parent2:SpriteVisualElement) {
			super();
			this.fillAlpha = 1;
			this.textColor = 0xffffffff;
			this.tooltipContainer = parent;
			this.directParent = parent2;
			
			textFormat = new TextFormat();
			textFormat.font = "FlamaBookMx2";
			textFormat.size = 12;
			textFormat.color = _textColor;
			textFormat.align="left";
			
			label = new TextField();
			label.selectable = false;
			label.embedFonts = true;
			label.mouseEnabled = false;
			label.defaultTextFormat = textFormat;
			label.width = 30; label.height = 20;	
			this.addChild(label);
			
			this.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
			this.addEventListener(MouseEvent.CLICK, mouseEventHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			tooltip = new RendererToolTip();
			tooltipContainer.addElement(tooltip);
			tooltip.visible = false;
		}		
		override public function set data(d:DataRow):void { 
			_data = d; 
			fillColor = textColor = d.country.region.color;
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
		
		override public function dirty():void {
			dirtyFlag = true;
			this.invalidateDisplayList();
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
			
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(dirtyFlag && stateFlag)
				draw();
			else if(!stateFlag) {
				graphics.clear();
				if(label)
					label.visible = false;
			}
		}
		protected function draw():void {
			var g:Graphics = this.graphics;//this.graphics;
			dirtyFlag = false;
			g.clear();
			var stroke:IStroke = new Stroke(_fillColor,1,1);
			stroke.apply(g,null,null);
			var matr:Matrix = new Matrix();
			matr.createGradientBox(_radius*2, _radius*2, Math.PI/1.7, 0, 0);
			var colors:Array;
			if(_fillAlpha > 0.2)
				colors = [_fillColor,Colors.darker(_fillColor)];
			else
				colors =  [_fillColor,_fillColor];
			g.beginGradientFill(DEFAULT_GRADIENTTYPE,colors,[_fillAlpha,_fillAlpha],FILL_RATIO,matr)			
			g.drawCircle(0, 0, _radius);
			g.endFill();	
			
			if(_radius < 30 && _radius > 15)  {
				textFormat.size = 10;
				label.visible = true;
			}
			else if(_radius <= 15)
				label.visible = false;
			else {
				textFormat.size = 12;
				label.visible = true;	
			}
			textFormat.color = _textColor;			
			label.text = _data.country.shortname
			label.x = -label.textWidth/2;
			label.y = -label.textHeight/2;
			label.width = label.textWidth+4;
			label.height = label.textHeight+4;	
			label.defaultTextFormat = textFormat;
			
			if(this.alpha == 0) {
				TweenNano.to(this,0.5,{delay:1,alpha:1});
				
			}
		}	
		private var offset:int = 15;
		protected function mouseEventHandler(event:Event):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					if(this.directParent.x + this.x + radius + tooltip.width > this.tooltipContainer.width) {
						tooltip.leftTip.visible = false;
						tooltip.rightTp.visible = true;
						tooltip.x = this.directParent.x +this.x - radius - tooltip.width - offset;
					}
					else { 
						tooltip.leftTip.visible = true;
						tooltip.rightTp.visible = false;
						tooltip.x = this.directParent.x + this.x + radius + offset;
					}
					tooltip.y = this.y - tooltip.height/2;
					tooltip.visible = true;	
					tooltip.country = data.country;
					break;
				}
					
				case MouseEvent.ROLL_OUT:
				{	
					tooltip.visible = false;
					break;
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
					if(!infoVisible) {
						tooltip.visible = false;
						info = new RendererInfo();
						info.country = _data.country;
						info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);

						if(this.directParent.x + this.x + radius + info.width > this.tooltipContainer.width) {
							info.leftTipVisible = false;
							info.rightTipVisible = true;
							info.x = this.directParent.x +this.x - radius - info.width - offset;
						}
						else { 
							info.leftTipVisible = true;
							info.rightTipVisible = false;
							info.x = this.directParent.x + this.x + radius + offset;
						}
						
						info.y = this.y+60;
						PopUpManager.addPopUp(info, this.parent, false);
						infoVisible = true;
					}
				}
			}
		}
		private function handleInfoClose(event:CloseEvent):void {
			infoVisible = false;
		}
		private function addedToStageHandler(event:Event):void {
			
		}
	}
	
}