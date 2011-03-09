package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.instance.view.visualizer.interfaces.IRenderer;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.utils.Colors;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.events.CloseEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;


	internal class MapRenderer extends BaseRenderer implements IRenderer
	{
		
		private var info:RendererInfo;
		protected var particle:MapParticle;
		public var countrySprite:Shape;
		
		public function MapRenderer(particle:MapParticle,parent:Group,parent2:DisplayObject) {
			super(parent,parent2);			
			tooltip = new RendererToolTip();
			tooltipContainer.addElement(RendererToolTip(tooltip));
			RendererToolTip(tooltip).visible = false;
		}		
		override public function set data(d:Object):void { 
			super.data = d;
			if(d)
				fillColor = textColor = DataRow(d).country.region.color;
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
				graphics.clear();
				if(labelTF)
					labelTF.visible = false;
			}
		}
		override protected function mouseEventHandler(event:Event):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					if(_data) {
						if(this.directParent.x + this.x + radius + RendererToolTip(tooltip).width + 10 > this.tooltipContainer.width) {
							RendererToolTip(tooltip).leftTip.visible = false;
							RendererToolTip(tooltip).rightTp.visible = true;
							RendererToolTip(tooltip).x = this.directParent.x +this.x - radius - RendererToolTip(tooltip).width - offset;
						}
						else { 
							RendererToolTip(tooltip).leftTip.visible = true;
							RendererToolTip(tooltip).rightTp.visible = false;
							RendererToolTip(tooltip).x = this.directParent.x + this.x + radius + offset;
						}
						RendererToolTip(tooltip).y = this.y - RendererToolTip(tooltip).height/2;
						RendererToolTip(tooltip).visible = true;	
						RendererToolTip(tooltip).content = _content;
						RendererToolTip(tooltip).country = _data.country;
					}
					break;
				}
				case MouseEvent.ROLL_OUT: 
				{	
					RendererToolTip(tooltip).visible = false;
					break;
				}		
				case MouseEvent.CLICK:
				{
					toggleInfo(true);
					break;
				}
			}
		}
		private function handleInfoClose(event:CloseEvent):void {
			infoVisible = false;
		}		
		public function draw():void {
			var g:Graphics = this.graphics;//this.graphics;
			dirtyFlag = false;
			g.clear();
			if(_data) {
				var stroke:IStroke = new Stroke(_fillColor,1,1);
				stroke.apply(g,null,null);
				var matr:Matrix = new Matrix();
				matr.createGradientBox(_radius*2, _radius*2, Math.PI/1.7, 0, 0);
				
				var colors:Array;
				if(_fillAlpha > 0.2) {
					colors = [_fillColor,Colors.darker(_fillColor)];
					_textColor = 0xffffff;
				}
				else {
					colors =  [_fillColor,_fillColor];
					_textColor = _fillColor;
				}
				g.beginGradientFill(DEFAULT_GRADIENTTYPE,colors,[_fillAlpha,_fillAlpha],FILL_RATIO,matr)			
				g.drawCircle(0, 0, _radius);
				g.endFill();	
				
				labelTF.text = DataRow(_data).country.shortname;
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
				
				labelTF.x = -labelTF.textWidth/2;
				labelTF.y = -labelTF.textHeight/2;
				labelTF.width = labelTF.textWidth+4;
				labelTF.height = labelTF.textHeight+4;	
				labelTF.defaultTextFormat = textFormat;
				
				if(this.alpha == 0) 
					TweenNano.to(this,0.5,{delay:1,alpha:1});
			}
		}	
		public function set content(v:String):void {
			_content = v;
			if(this.infoVisible) {
				info.content = v;
			}
		}
		public function toggleInfo(visible:Boolean):void {
			if(!visible && infoVisible) {
				this.info.close();
			}
			else if(visible && !infoVisible && _data) {
				RendererToolTip(tooltip).visible = false;
				info = new RendererInfo();
				info.country = _data.country;
				info.content = _content;
				info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				moveInfo();
				PopUpManager.addPopUp(info, this.parent, false);
			}	
			infoVisible = visible;
		}
		override public function moveInfo():void {
			if(this.directParent.x + this.x + radius + info.width + 10 > this.tooltipContainer.width) {
				info.leftTipVisible = false;
				info.rightTipVisible = true;
				info.x = this.directParent.x +this.x - radius - info.width - offset;
			}
			else { 
				info.leftTipVisible = true;
				info.rightTipVisible = false;
				info.x = this.directParent.x + this.x + radius + offset;
			}
			info.y = this.y - this.height/2 + 34;
		}
	}
}