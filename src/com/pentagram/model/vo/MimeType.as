package com.pentagram.model.vo
{

	public class MimeType
	{
		public static const NONE:MimeType = new MimeType(0,"NONE");
		public static const IMAGE:MimeType = new MimeType(1,"images");
		public static const VIDEO:MimeType = new MimeType(2,"video");
		public static const AUDIO:MimeType = new MimeType(3,"audio"); 
		public static const SWF:MimeType = new MimeType(4,"swf");
		public static const FILE:MimeType = new MimeType(5,"file");
		public static const YOUTUBE:MimeType = new MimeType(6,"youtube");	
		public static const FONT:MimeType = new MimeType(7,"font");
		public static const DIRECTORY:MimeType = new MimeType(8,"directory");
		
		
		public function MimeType(id:int,name:String)
		{
			this.id = id;
			this.name = name;
		}

		public static function get list( ):Array
		{
			return [NONE,IMAGE,VIDEO,AUDIO,SWF,FILE,YOUTUBE,FONT,DIRECTORY];
		}
		public var id:int;
		public var name:String;
		
		public static function getMimetype(extension:String):MimeType
		{
			extension = extension.toLowerCase();
			switch(extension) {
				case "jpg": case "jpeg": case "png": case "gif": case "bmp":
					return IMAGE;
				break;
				case "flv","f4v","mov","m4v":
					return VIDEO;
				break;
				case "swf":
					return SWF;
				break;
				case "ttf","otf":
					return FONT;
				break;
				case "mp3":
					return AUDIO;
				break;
				default:
					return FILE;				
			}
		}
	}
}