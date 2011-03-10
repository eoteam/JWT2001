package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.instance.view.visualizer.interfaces.IRenderer;
	import com.pentagram.model.vo.DataRow;
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

	public class ClusterRenderer extends BaseRenderer
	{
		public var radiusCopy:Number;
		private var info:RendererInfo;
		
		public function ClusterRenderer(parent:Group,parent2:SpriteVisualElement) {
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
		private var _data2:DataRow;
		public function set data2(d:DataRow):void {
			_data2 = d;
			if(!data)
				fillColor = textColor = _data2.country.region.color
		}
		public function get data2():DataRow {
			return _data2;
		}
		public function set state(value:Boolean):void {
			if(value && !stateFlag)
				dirtyFlag = true;
			stateFlag = value;
			this.updateDisplayList();
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
		override protected function mouseEventHandler(event:Event):void {
			var mouseEvent:MouseEvent = event as MouseEvent;
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					if(_data || _data2) {
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
						RendererToolTip(tooltip).country = _data?_data.country:_data2.country;
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
		override public function draw():void {
			super.draw();
			labelTF.text = _data?DataRow(_data).country.shortname:DataRow(_data2).country.shortname;
			if(this.alpha == 0) 
				TweenNano.to(this,0.5,{delay:1,alpha:1});
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
			else if(visible && !infoVisible && (_data || _data2)) {
				RendererToolTip(tooltip).visible = false;
				info = new RendererInfo();
				info.country = _data?_data.country:_data2.country;
				info.content = _content;
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
			info.y = this.y+38-15;// - this.height/2 + 34;
		}
	}
}