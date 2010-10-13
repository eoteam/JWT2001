package com.pentagram.model.vo
{
	import mx.collections.ArrayCollection;

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
		
		public var datasets:ArrayCollection;
		
		public var tags:String='';
		public var relatedcontent:String;
	}
}