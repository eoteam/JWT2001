package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.model.vo.TwitterTopic;
	import com.pentagram.utils.Colors;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.events.CloseEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	public class TwitterRenderer extends BaseRenderer
	{	
		private var info:TWRendererInfo;

		public function TwitterRenderer(parent:Group,parent2:SpriteVisualElement) {
			super(parent,parent2);	
			tooltip = new TWRendererToolTip();
			tooltipContainer.addElement(TWRendererToolTip(tooltip));
			TWRendererToolTip(tooltip).visible = false;
		}		
		public function set state(value:Boolean):void {
			if(value && !stateFlag)
				dirtyFlag = true;
			stateFlag = value;
		}
		public function get state():Boolean {
			return stateFlag;
		}

		override protected function updateDisplayList():void
		{
			//super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(dirtyFlag && stateFlag)
				draw();
			else if(!stateFlag) {
				graphics.clear();
				if(labelTF)
					labelTF.visible = false;
			}
		}

		override public function set data(d:Object):void {
			super.data = d;
			content =  '<P ALIGN="left"><FONT FACE="FlamaBook" SIZE="12" COLOR="#cccccc" LETTERSPACING="0" KERNING="1">'+
						'Results: <FONT COLOR="#ffffff">'+_data.count+'</FONT></FONT></P>';
		}
		
		public function draw():void {
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
			
			labelTF.text = _data.value;
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
			
			labelTF.x = labelTF.textWidth/2;
			labelTF.y = -labelTF.textHeight/2;
			labelTF.width = labelTF.textWidth+4;
			labelTF.height = labelTF.textHeight+4;	
			labelTF.defaultTextFormat = textFormat;
			
			if(this.alpha == 0) {
				TweenNano.to(this,0.5,{delay:1,alpha:1});
				
			}
		}	
		override protected function mouseEventHandler(event:Event):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					if(this.directParent.x + this.x + radius + TWRendererToolTip(tooltip).width + 10 > this.tooltipContainer.width) {
						TWRendererToolTip(tooltip).leftTip.visible = false;
						TWRendererToolTip(tooltip).rightTp.visible = true;
						TWRendererToolTip(tooltip).x = this.directParent.x +this.x - radius - TWRendererToolTip(tooltip).width - offset;
					}
					else { 
						TWRendererToolTip(tooltip).leftTip.visible = true;
						TWRendererToolTip(tooltip).rightTp.visible = false;
						TWRendererToolTip(tooltip).x = this.directParent.x + this.x + radius + offset;
					}
					TWRendererToolTip(tooltip).y = this.y - TWRendererToolTip(tooltip).height/2;
					TWRendererToolTip(tooltip).topic = this._data as TwitterTopic;
					TWRendererToolTip(tooltip).visible = true;	
					TWRendererToolTip(tooltip).content = _content;
					break;
				}
					
				case MouseEvent.ROLL_OUT:
				{	
					TWRendererToolTip(tooltip).visible = false;
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
				tooltip.visible = false;
				info = new TWRendererInfo();
				info.content = _content;
				info.topic = _data as TwitterTopic;
				info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				moveInfo();
				PopUpManager.addPopUp(info, this.tooltipContainer, false);
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
			info.y = this.y+45;// - this.height/2 + 34;
		}
	}
}