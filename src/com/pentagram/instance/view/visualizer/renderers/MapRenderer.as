package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenLite;
	import com.pentagram.instance.view.visualizer.interfaces.IRenderer;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.utils.Colors;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
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


	public class MapRenderer extends BaseRenderer
	{
		protected var particle:MapParticle;
		public var countrySprite:Shape;
		public var id:String;
		
		public function MapRenderer(particle:MapParticle,parent:Group,parent2:DisplayObject) {
			super(parent,parent2);
			labelTF.rotationY = 0;
			tooltip = new RendererToolTip();
			tooltipContainer.addElement(RendererToolTip(tooltip));
			RendererToolTip(tooltip).visible = false;
		}	
		override public function set data(d:Object):void { 
			_data = d;
			if(d)
				fillColor = textColor = DataRow(d).country.region.color;
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
		override public function draw():void {
			if(_data) {
				labelTF.text = DataRow(_data).country.shortname;
				super.draw();
			}
			else
				this.graphics.clear();
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
				RendererToolTip(tooltip).visible = false;
				info = new RendererInfo();
				info.data = _data.country;
				info.content = _content;
				info.addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				moveInfo();
				PopUpManager.addPopUp(info as RendererInfo, this.tooltipContainer, false);
			}	
			infoVisible = visible;
		}
		override public function moveInfo():void {
			if(this.directParent.x + this.x + radius + info.width + 10 > this.tooltipContainer.width) {
				RendererInfo(info).leftTipVisible = false;
				RendererInfo(info).rightTipVisible = true;
				info.x = this.directParent.x +this.x - radius - info.width - offset;
			}
			else { 
				RendererInfo(info).leftTipVisible = true;
				RendererInfo(info).rightTipVisible = false;
				info.x = this.directParent.x + this.x + radius + offset;
			}
			info.y = this.y+38-15;
		}
		override public function set x(value:Number):void {
			super.x = value;
		}
		override public function set y(value:Number):void {
			super.y = value;
		}
		public function move(x:Number,y:Number):void {
			this.x = x;
			this.y = y;
			if(infoVisible && info.pinned) 
				moveInfo();
		}
		override public function set radius(r:Number):void {
			_radius = r;
			if(isNaN(_radius))
				_radius = 0;			
		}
	}
}