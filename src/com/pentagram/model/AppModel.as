package com.pentagram.model
{
	import com.pentagram.model.vo.Country;
	import com.pentagram.model.vo.Region;
	import com.pentagram.model.vo.User;
	import com.pentagram.utils.ViewUtils;
	
	import mx.collections.ArrayList;
	
	import org.robotlegs.mvcs.Actor;

	public class AppModel extends Actor
	{
		public function AppModel()
		{
			colors = new Vector.<uint>();
		}

		[Bindable]
		public var regions:ArrayList;
		
		[Bindable]
		public var countries:ArrayList;
		
		[Bindable]
		public var clients:ArrayList;
		
		public var colors:Vector.<uint>;
		public var loggedIn:Boolean = false;
		
		public var user:User;	
		
		public function cloneRegions():Array {
			var result:ArrayList = new ArrayList();
			var countries:ArrayList = new ArrayList();
			for each(var region:Region in regions.source) {
				var r:Region = ViewUtils.clone(region) as Region;
				r.countries = new ArrayList();
				for each(var country:Country in region.countries.source) {
					var c:Country = ViewUtils.clone(country) as Country;
					c.region = r;
					countries.addItem(c);
					r.countries.addItem(c);
				}
				r.selected = true;
				result.addItem(r);
			}
//			var r:Region = new Region();
//			r.fxgmap = region.fxgmap;
//			r.countries = region.countries;
//			r.coeff = region.coeff;
//			r.color = region.color;
//			r.id = region.id;
//			r.name = region.name;
//			r.selected = true;
			return [result,countries];
		}
	}
}