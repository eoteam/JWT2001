package com.pentagram.model.vo
{
	[Bindable]
	public class User extends BaseVO
	{
		public var email:String;
		public var active:int;
		public var username:String;
		public var firstname:String;
		public var lastname:String;
		public var password:String;
		public var lastlogin:Number;
				
		public function toString():String {
			return firstname+" " +lastname;
		}
		public function get fullname():String {
			return firstname+" " +lastname;
		}
		public function set fullname(value:String):void {
			
		}
	}
}