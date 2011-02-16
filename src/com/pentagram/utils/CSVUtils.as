package com.pentagram.utils
{
	public class CSVUtils
	{
		import mx.collections.ArrayCollection;
				
		public static var DEFAULT_SPLITTER:String = ",";
		
		public static const LINE_SPLLITER:String = "\n";
		
		public static function CsvToArray(csv_str:String):Array {
			return CsvToArray_spl(csv_str, DEFAULT_SPLITTER);
		}
		
		
		public static function TsvToArray(tsv_str:String):Array {
			return CsvToArray_spl(tsv_str, "\t");
		}
		
		public static function CsvToArray_spl(csv_str:String, splitter:String):Array {
			var csv:CSVUtils = new CSVUtils();
			return csv.split(csv_str, splitter);
		}
		
		public static function replaceStr(str:String, a:String, b:String):String {
			var o:Array = str.split(a);
			return o.join(b);
		}
		
		public static function ArrayToArrayCollection(csv_ary:Array,
													  mapping:Array, topline_is_header:Boolean = false):ArrayCollection {
			if (topline_is_header) { // ï¼‘è¡Œç›®ã‚’ãƒ˜ãƒƒãƒ€ã¨ã—ã¦ä½¿ã†ãªã‚‰å‰Šã‚‹
				csv_ary.splice(0, 1);
			}
			var result_ary:ArrayCollection = new ArrayCollection();
			for (var row:int = 0; row < csv_ary.length; row++) {
				var cols:Array = csv_ary[row];
				var col_obj:Object = {};
				for (var col:int = 0; col < mapping.length; col++) {
					var field_name:String = mapping[col];
					var col_str:String = cols[col];
					if (field_name == ""||field_name == null) continue;
					col_obj[field_name] = col_str;
				}
				result_ary.addItem(col_obj);
			}
			return result_ary;
		}
		
		public static function ArrayToCsv(csv_ary:Array, splitter:String,
										  use_escape:Boolean = false):String {
			var res:String = "";
			for (var row:int = 0; row < csv_ary.length; row++) {
				var cols:Array = csv_ary[row];
				for (var col:int = 0; col <  cols.length; col++) {
					var cell:String = cols[col];
					if (use_escape || hasEscapeChar(cell, splitter)) {
						cell = escapeCell(cell);
					}
					res += cell + splitter;
				}
				if (cols.length > 0) res = res.substr(0, res.length -1);
				res += LINE_SPLLITER;
			}
			if (csv_ary.length > 0) res = res.substr(0, res.length - 1);
			return res;
		}
		/**
		 * æ–‡å­—åˆ—ã‚’ ".." ã§æ‹¬ã‚‹å¿…è¦ãŒã‚ã‚‹ã‹ãƒã‚§ãƒƒã‚¯ã™ã‚‹
		 */
		public static function hasEscapeChar(cell:String, splitter:String):Boolean {
			if (cell.indexOf('"') >= 0) return true;
			if (cell.indexOf("\n") >= 0) return true;
			if (cell.indexOf("\r") >= 0) return true;
			if (cell.indexOf("\t") >= 0) return true;
			if (cell.indexOf(" ") >= 0) return true;
			if (cell.indexOf(splitter) >= 0) return true;
			return false;
		}
		/**
		 * CSVã®ã‚»ãƒ«(æ–‡å­—åˆ—)ã‚’ ".." ã§æ‹¬ã£ã¦ã‚¨ã‚¹ã‚±ãƒ¼ãƒ—ã™ã‚‹
		 */
		public static function escapeCell(cell:String):String {
			cell = replaceStr(cell, '"', '""');
			cell = '"' + cell + '"';
			return cell;
		}
		// ------------------
		// CSVUtils ã‚¯ãƒ©ã‚¹
		private var csv_str:String;
		private var splitter:String;
		private var index:int;
		
		public function split(csv_str:String, splitter:String):Array {
			// æ”¹è¡Œã‚’çµ±ä¸€ã™ã‚‹
			csv_str = replaceStr(csv_str, "\r\n", LINE_SPLLITER);
			csv_str = replaceStr(csv_str, "\r", LINE_SPLLITER);
			//
			this.csv_str = csv_str;
			this.splitter = splitter;
			//
			return splitLoop();
		}
		private function splitLoop():Array {
			var result:Array = [];
			while (csv_str.length > 0) {
				var cols:Array = getCols();
				result.push(cols);
			}
			return result;
		}
		private function getCols():Array {
			var cols:Array = [];
			index = 0;
			while (index < csv_str.length) {
				var c:String = csv_str.charAt(index);
				var col:String;
				if (c == LINE_SPLLITER) {
					index++;
					break;
				}
				if (c == '"') {
					col = getColStr();
				}
				else {
					col = getColSimple();  
				}
				skipSpace();
				cols.push(col);
			}
			// åˆ‡ã‚Šå–ã‚‹
			csv_str = csv_str.substr(index);
			return cols;
		}
		private function getColSimple():String {
			var col:String = "";
			while (index < csv_str.length) {
				if (csv_str.substr(index, 2) == '""') {
					col += '"';
					index += 2;
					continue;
				}
				var c:String = csv_str.charAt(index);
				if (c == splitter) {
					index++;
					break;
				}
				if (c == LINE_SPLLITER) {
					break;
				}
				col += c;
				index++;                
			}
			return col;
		}
		private function getColStr():String {
			// "str" ã®æ–‡å­—åˆ—
			index++; // skip '"'
			var col:String = "";
			while (index < csv_str.length) {
				if (csv_str.substr(index, 2) == '""') {
					col += '"';
					index += 2;
					continue;
				}
				var c:String = csv_str.charAt(index);
				if (c == '"') { // çµ‚ç«¯ '"' ã®å¯èƒ½æ€§
					index++;
					skipSpace();
					// çµ‚ç«¯ã®ã¯ãšã€ã‚‚ã—é•ãˆã°ã€å£Šã‚ŒãŸå½¢å¼ã®å¯èƒ½æ€§ãŒã‚ã‚‹ãŒç¶™ç¶šã™ã‚‹
					if (csv_str.charAt(index) == ",") {
						index++;
					}
					break;
				}
				col += c;
				index++;                
			}
			return col;
		}
		private function skipSpace():void {
			if (csv_str.charAt(index) == " ") {
				index++;
			}
		}
	}
}

