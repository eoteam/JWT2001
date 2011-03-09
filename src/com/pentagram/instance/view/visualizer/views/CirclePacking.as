package com.pentagram.instance.view.visualizer.views
{
	import com.greensock.TweenNano;
	import com.pentagram.instance.model.vo.Point3D;
	import com.pentagram.instance.view.visualizer.renderers.ClusterRenderer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;

	public class CirclePacking extends SpriteVisualElement
	{	 
		public var renderers:Vector.<ClusterRenderer> = new Vector.<ClusterRenderer>;
		public var filteredRenderers:Vector.<ClusterRenderer> = new Vector.<ClusterRenderer>;
		public var dataProvider:Array = [];
		public var scaler:Number = 1;
		
		protected var tooltipContainer:Group;
		protected var animateCoord:Boolean = false;
		public var filterMode:Boolean = false;
		
		private var circlePositions:Vector.<Point3D>;
		private var filteredPositions:Vector.<Point3D>;
		
		private var MIN_SPACE_BETWEEN_CIRCLES:uint = 2;
		private var opacity:Boolean;
				
		public function CirclePacking(arr:Array,parent:Group,opacity:Boolean)
		{
			super();			
			this.dataProvider = arr;
			this.tooltipContainer = parent;
			this.opacity = opacity;
		}
		public function build():void {
			var counter:uint = 0;
			while(counter < dataProvider.length) {
				var sprite:ClusterRenderer = new  ClusterRenderer(tooltipContainer,this); 
				sprite.data = dataProvider[counter].data;
				sprite.data2 = dataProvider[counter].data2; 
				sprite.fillColor = dataProvider[counter].color;
				sprite.fillAlpha = opacity?0.2:1;
				sprite.content = dataProvider[counter].content;
				sprite.textColor = opacity?dataProvider[counter].color:0xffffff;
				sprite.radiusBeforeRendering = dataProvider[counter].radius;
				sprite.radiusCopy = dataProvider[counter].radius;
				sprite.scaleX= -1;
				renderers.push(sprite);
				this.addChild(sprite);
				counter++;
			}
			if(renderers.length >= 2)
				doLayout();
		}
		public function restore():void {
			filterMode = false;
			this.draw();
		}
		public function doLayout(animate:Boolean=false):void {
			animateCoord = animate;
			filterMode = false;
			var disposeCounter:int = 2;
			var c:ClusterRenderer = null;
			var _loc_2:Number = NaN;
			var _loc_7:uint = 0;
			var _loc_3:Number = 0;
			var _loc_4:* = new Point();

			circlePositions = new Vector.<Point3D>;			
			circlePositions.push(new Point3D(0, 0, this.renderers[0].radiusBeforeRendering));
			circlePositions.push(new Point3D(this.renderers[0].radiusBeforeRendering + this.renderers[1].radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES, 0,this.renderers[1].radiusBeforeRendering));
			var _loc_5:Number = this.circlePositions[1].x + this.circlePositions[1].z;
			while (disposeCounter < this.dataProvider.length){
				
				c = this.renderers[disposeCounter];
				//this.graphics.moveTo(0, 0);
				_loc_2 = this.renderers[0].radiusBeforeRendering + c.radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES;
				_loc_3 = 2 * Math.PI * Math.random();
				_loc_7 = 0;
				while (_loc_7 < 5000) {
					
					_loc_4.x = _loc_2 * Math.cos(_loc_3);
					_loc_4.y = _loc_2 * Math.sin(_loc_3);
					_loc_2 = _loc_2 + 0.2;
					_loc_3 = _loc_3 + _loc_2 * 0.001;
					if (this.testCircleAtPoint(_loc_4, c.radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES,circlePositions)){
						this.circlePositions.push(new Point3D(_loc_4.x, _loc_4.y, c.radiusBeforeRendering));
						_loc_5 = Math.max(_loc_5, Math.sqrt(Math.pow(_loc_4.x, 2) + Math.pow(_loc_4.y, 2)) + c.radiusBeforeRendering);
						break;
					}
					_loc_7 = _loc_7 + 1;
				}
				draw();
				disposeCounter++;
			}
			for each(var pos:Point3D in circlePositions) {
				pos.x = pos.x /_loc_5;
				pos.y = pos.y / _loc_5;
				pos.z = pos.z / _loc_5;
			}
			draw();
			animateCoord = false;
		}
		
		public function filter():void {
			filterMode = true;

			var disposeCounter:int = 2;
			var c:ClusterRenderer = null;
			var _loc_2:Number = NaN;
			var _loc_7:uint = 0;
			var _loc_3:Number = 0;
			var _loc_4:* = new Point();
			filteredPositions = new Vector.<Point3D>;	
			if(filteredRenderers.length > 2) {
						
				filteredPositions.push(new Point3D(0, 0, filteredRenderers[0].radiusBeforeRendering));
				filteredPositions.push(new Point3D(filteredRenderers[0].radiusBeforeRendering + filteredRenderers[1].radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES, 0,filteredRenderers[1].radiusBeforeRendering));
				var _loc_5:Number = filteredPositions[1].x + filteredPositions[1].z;
				
				while (disposeCounter < filteredRenderers.length){
					
					c = filteredRenderers[disposeCounter];
					//this.graphics.moveTo(0, 0);
					_loc_2 = filteredRenderers[0].radiusBeforeRendering + c.radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES;
					_loc_3 = 2 * Math.PI * Math.random();
					_loc_7 = 0;
					while (_loc_7 < 5000) {
						
						_loc_4.x = _loc_2 * Math.cos(_loc_3);
						_loc_4.y = _loc_2 * Math.sin(_loc_3);
						_loc_2 = _loc_2 + 0.2;
						_loc_3 = _loc_3 + _loc_2 * 0.001;
						if (this.testCircleAtPoint(_loc_4, c.radiusBeforeRendering + MIN_SPACE_BETWEEN_CIRCLES,filteredPositions)){
							this.filteredPositions.push(new Point3D(_loc_4.x, _loc_4.y, c.radiusBeforeRendering));
							_loc_5 = Math.max(_loc_5, Math.sqrt(Math.pow(_loc_4.x, 2) + Math.pow(_loc_4.y, 2)) + c.radiusBeforeRendering);
							break;
						}
						_loc_7 = _loc_7 + 1;
					}
					draw();
					disposeCounter++;
				}
				for each(var pos:Point3D in filteredPositions) {
					pos.x = pos.x /_loc_5;
					pos.y = pos.y / _loc_5;
					pos.z = pos.z / _loc_5;
				}
				draw();
			}
		}
		protected function testCircleAtPoint(point:Point, radius:Number,positions:Vector.<Point3D>) : Boolean {
			var _loc_3:uint = 1;
			while (_loc_3 < positions.length){
				
				if (Math.sqrt(Math.pow(positions[_loc_3].x - point.x, 2) + Math.pow(positions[_loc_3].y - point.y, 2)) < positions[_loc_3].z + radius){
					return false;
				}
				_loc_3 = _loc_3 + 1;
			}
			return true;
		}
		
		public function draw(): void {			
			var c:ClusterRenderer;
			var _loc_2:Number = Math.floor(Math.min(width, height) * 0.5) - 3;
			if (this.renderers.length < 2){
					c = this.renderers[0];
					TweenNano.to(c,.5,{radius:25 * scaler,
						alpha:1,
						x:_loc_2 + width/2,
						y:_loc_2+ height/2});		
				
				return;
			}
			
			var i:uint = 0;
			var dp:Vector.<Point3D> = filterMode?filteredPositions:circlePositions;
			var rends:Vector.<ClusterRenderer> = filterMode?filteredRenderers:renderers;
			
			while (i < dp.length){
				c = rends[i];
				c.state = true;
				c.point = dp[i];
				if(animateCoord) {
					c.alpha = 0;
					TweenNano.to(c,.5,{radius:dp[i].z * _loc_2 * scaler,
									   alpha:1,
									   x:dp[i].x * _loc_2 + width/2,
									   y:dp[i].y * _loc_2+ height/2});					
				}
				else {
					c.x =  dp[i].x * _loc_2 + width/2;
					c.y = dp[i].y * _loc_2+ height/2;
					TweenNano.to(c,.5,{radius:dp[i].z * _loc_2 * scaler});
				}
				i++;
			}
			cacheAsBitmap = true;
		}
		public function hide():void {
			this.includeInLayout = this.visible = animateCoord =false;
			for each(var c:ClusterRenderer in this.renderers) {
				c.toggleInfo(false);
			}
		}
		public function show():void {
			this.includeInLayout = this.visible = true;
			animateCoord = false;

		}
	}
}		