package com.pentagram.model.vo
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	[Bindable]
	public class Client extends BaseVO
	{
		public var shortname:String;
		public var employees:String;
		public var founded:int;
		public var headquarters:String;
		public var website:String;
		public var description:String;
		public var thumb:String;
		
		
		public var datasets:ArrayList;
		public var quantityDatasets:ArrayList;
		public var qualityDatasets:ArrayList;
		
		public var countries:ArrayList = new ArrayList();
		public var regions:ArrayList = new ArrayList();
		
		public var newCountries:ArrayList = new ArrayList();
		public var deletedCountries:ArrayList = new ArrayList();
		
	
		//.<String> = new Vector.<String>();
		
		public var loaded:Boolean = false;
		public var created:Boolean = true;
		
		public var tags:String='';
		public var relatedcontent:String;
		
		public function Client(created:Boolean = true) {
			this.created = created;
		}
		
		public var notes:ArrayCollection = new ArrayCollection();
	}
}