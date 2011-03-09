package com.pentagram.instance.view.visualizer.renderers
{
	import com.greensock.TweenNano;
	import com.pentagram.instance.view.visualizer.interfaces.IRenderer;
	import com.pentagram.model.vo.DataRow;
	import com.pentagram.utils.Colors;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.events.CloseEvent;
	import mx.events.ToolTipEvent;
	import mx.graphics.IStroke;
	import mx.graphics.Stroke;
	import mx.managers.PopUpManager;
	
	import org.cove.ape.APEngine;
	import org.cove.ape.CircleParticle;
	
	import spark.components.Group;
	
	public class MapParticle extends CircleParticle
	{
		
		protected var _data:DataRow;
		
		public function MapParticle(engine:APEngine,parent:Group,radius:Number=1, fixed:Boolean=false, mass:Number=1, elasticity:Number=0.3, friction:Number=0)
		{
			_sprite = new MapRenderer(this,parent,parent);
			super(engine,0, 0, radius, fixed, mass, elasticity, friction);
			this.collidable = true;
			this.alwaysRepaint = true;
			engine.container.addChild(_sprite);
		}
		public function get data():DataRow { return _data; }
		public function set data(d:DataRow):void { 
			_data = d;
			fillColor=d.country.region.color;
			if(_sprite)
				MapRenderer(_sprite).data = d;
		}	
		override public function set radius(r:Number):void {
			if(isNaN(r)) this.collidable = false;
			else this.collidable = true;
			if(r < 0)
				visible = false;
			if(_sprite)
				MapRenderer(_sprite).radius = r;
			super.radius = r;
		}

		override public function set fillColor(c:uint):void { 
			MapRenderer(_sprite).fillColor = _fillColor = c;
		}
		override public function set textColor(c:uint):void { 
			MapRenderer(_sprite).textColor = _textColor = c;	
		}
		override public function set fillAlpha(a:Number):void {
			MapRenderer(_sprite).fillAlpha = _fillAlpha = a;
		}

		public function draw(coord:Boolean):void {
			var countrySprite:Shape = MapRenderer(_sprite).countrySprite;
			if(countrySprite) {
				if(!coord) {
					var pt:Point = countrySprite.parent.localToGlobal(new Point(countrySprite.x,countrySprite.y));
					pt = _sprite.parent.globalToLocal(pt);
					px = pt.x; py = pt.y;
					if(_sprite) 
						MapRenderer(_sprite).move(pt.x,pt.y);
				}
				if(_visible) {
					MapRenderer(_sprite).draw();
				}
				if(_sprite.visible != _visible) {
					if(_visible) {
						_sprite.visible = true;
						TweenNano.to(_sprite,0.5,{alpha:1});
					}	
					else
						TweenNano.to(_sprite,0.1,{alpha:0,onComplete:hide});
				}
			}
			
		}
		public function set countrySprite(value:Shape):void {
			MapRenderer(_sprite).countrySprite = value;
		}
		private function hide():void {
			_sprite.visible = false;
		}

		override public function set visible(v:Boolean):void {
			_visible = v;
			this.collidable = v;
		}
	}
}	