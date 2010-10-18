package com.pentagram.model.vo
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	[Bindable]
	public class Client extends BaseVO
	{
		public var shortname:String;
		public var employees:int;
		public var founded:int;
		public var headquarters:String;
		public var website:String;
		public var description:String;
		public var thumbs:String;
		
		public var datasets:ArrayList;
		public var countries:ArrayList = new ArrayList();
		public var newCountries:Array = [];
		public var deletedCountries:Array = [];
		
		public var tags:String='';
		public var relatedcontent:String;
		

		
	}
}