package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenLite;
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
		override public function toggleTooltip(visible:Boolean):void {
			if(visible) {
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
			}
			else
				RendererToolTip(tooltip).visible = false;
				
		}
		override public function draw():void {
			labelTF.text = _data?DataRow(_data).country.shortname:DataRow(_data2).country.shortname;
			super.draw();
		}	
		override public function set content(v:String):void {
			super.content = v;
			if(this.infoVisible) {
				info.content = v;
			}
		}
		override public function toggleInfo(visible:Boolean):void {
			super.toggleTooltip(visible);
			if(!visible && infoVisible) {
				this.info.close();
			}
			else if(visible && !infoVisible && (_data || _data2)) {
				RendererToolTip(tooltip).visible = false;
				info = new RendererInfo();
				info.data = _data?_data.country:_data2.country;
				info.content = _content;
				RendererInfo(info).addEventListener(CloseEvent.CLOSE,handleInfoClose,false,0,true);
				moveInfo();
				PopUpManager.addPopUp(info as RendererInfo, this.tooltipContainer, false);
			}	
			infoVisible = visible;
		}
		override public function moveInfo():void {
			if(this.directParent.x + this.x + radius + RendererInfo(info).width + 10 > this.tooltipContainer.width) {
				RendererInfo(info).leftTipVisible = false;
				RendererInfo(info).rightTipVisible = true;
				RendererInfo(info).x = this.directParent.x +this.x - radius - RendererInfo(info).width - offset;
			}
			else { 
				RendererInfo(info).leftTipVisible = true;
				RendererInfo(info).rightTipVisible = false;
				RendererInfo(info).x = this.directParent.x + this.x + radius + offset;
			}
			RendererInfo(info).y = this.y+38-15;// - this.height/2 + 34;
		}
	}
}