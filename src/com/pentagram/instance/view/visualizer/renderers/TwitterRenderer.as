package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenLite;
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
		public function TwitterRenderer(parent:Group,parent2:SpriteVisualElement) {
			super(parent,parent2);	
			tooltip = new TWRendererToolTip();
			tooltipContainer.addElement(TWRendererToolTip(tooltip));
			TWRendererToolTip(tooltip).visible = false;
		}		
//		public function set state(value:Boolean):void {
//			if(value && !stateFlag)
//				dirtyFlag = true;
//			stateFlag = value;
//		}
//		public function get state():Boolean {
//			return stateFlag;
//		}

//		protected function updateDisplayList():void
//		{
//			//super.updateDisplayList(unscaledWidth,unscaledHeight);
//			if(dirtyFlag && stateFlag)
//				draw();
//			else if(!stateFlag) {
//				graphics.clear();
//				if(labelTF)
//					labelTF.visible = false;
//			}
//		}

		override public function set data(d:Object):void {
			super.data = d;
			content =  '<P ALIGN="left"><FONT FACE="FlamaBook" SIZE="12" COLOR="#cccccc" LETTERSPACING="0" KERNING="1">'+
						'Results: <FONT COLOR="#ffffff">'+_data.count+'</FONT></FONT></P>';
		}
		
		override public function draw():void {
			labelTF.text = _data.value;
			super.draw();			
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
		override public function set content(v:String):void {
			super.content = v;
			if(this.infoVisible) {
				info.content = v;
			}
		}
		override public function toggleInfo(visible:Boolean):void {
			if(!visible && infoVisible) {
				this.info.close();
			}
			else if(visible && !infoVisible && _data) {
				tooltip.visible = false;
				info = new TWRendererInfo();
				info.content = _content;
				info.data = _data as TwitterTopic;
				info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				moveInfo();
				PopUpManager.addPopUp(info as TWRendererInfo, this.tooltipContainer, false);
			}	
			infoVisible = visible;
		}
		override public function moveInfo():void {
			if(this.directParent.x + this.x + radius + info.width + 10 > this.tooltipContainer.width) {
				TWRendererInfo(info).leftTipVisible = false;
				TWRendererInfo(info).rightTipVisible = true;
				info.x = this.directParent.x + this.x - radius - info.width - offset;
			}
			else { 
				TWRendererInfo(info).leftTipVisible = true;
				TWRendererInfo(info).rightTipVisible = false;
				info.x = this.directParent.x + this.x + radius + offset;
			}
			info.y = this.y+64.5-15;
		}
	}
}