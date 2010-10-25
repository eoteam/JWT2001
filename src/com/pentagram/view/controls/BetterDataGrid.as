package com.pentagram.view.controls
{
import flash.geom.Point;
import mx.collections.CursorBookmark;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.DataGrid;

import mx.core.mx_internal;
use namespace mx_internal;

	
/**
 *  A DataGrid subclass that has faster horizontal scrolling
 */
public class BetterDataGrid extends DataGrid
{
	public function BetterDataGrid()
	{
		super(); 
	}

	/** 
	 *  remember the number of columns in case it changes
	 */
	private var lastNumberOfColumns:int;

	/**
	 *  a flag as to whether we can use the optimized scrolling
	 */
	private var canUseScrollH:Boolean;

	/**
	 *  when the horizontal scrollbar is changed it will eventually set horizontalScrollPosition
	 *  This value can be set programmatically as well.
	 */
	override public function set horizontalScrollPosition(value:Number):void
	{
		// remember the setting of this flag.  We will tweak it in order to keep DataGrid from
		// doing its default horizontal scroll which essentially refreshes every renderer
		var lastItemsSizeChanged:Boolean = itemsSizeChanged;

		// remember the current number of visible columns.  This can get changed by DataGrid
		// as it recomputes the visible columns when horizontally scrolled.
		lastNumberOfColumns = visibleColumns.length;

		// reset the flag for whether we use our new technique
		canUseScrollH = false;

		// call the base class.  If we can use our technique we'll trip that flag
		super.horizontalScrollPosition = value;

		// if the flag got tripped run our new technique
		if (canUseScrollH)
			scrollLeftOrRight();

		// reset the flag
		itemsSizeChanged = lastItemsSizeChanged;

	}

	// remember the parameters to scrollHorizontally to be used in our new technique
	private var pos:int;
	private var deltaPos:int;
	private var scrollUp:Boolean;

	// override this method.  If it gets called that means we can use the new technique
	override protected function scrollHorizontally(pos:int, deltaPos:int, scrollUp:Boolean):void
	{
		// just remember the args for later;
		this.pos = pos;
		this.deltaPos = deltaPos;
		this.scrollUp = scrollUp;
		if (deltaPos < visibleColumns.length)
		{
			canUseScrollH = true;

			// need this to prevent DG from asking for a full refresh
			itemsSizeChanged = true;
		}
	}

	/**
	 *  The new technique does roughly what we do vertically.  We shift the renderers on screen and in the
	 *  listItems array and only make the new renderers.
	 *  Because we can't get internal access to the header, we fully refresh it, but that's only one row
	 *  of renderers.  There's significant gains to be made by not fully refreshing the every row of columns
	 *
	 *  Key thing to note here is that visibleColumns has been updated, but the renderer array has not
	 *  That's why we don't do this in scrollHorizontally as the visibleColumns hasn't been updated yet
	 *  But because of that, sometimes we have to measure old renderers, and sometimes we measure the columns
	 */
	private function scrollLeftOrRight():void
	{
        // trace("scrollHorizontally " + pos);
        var i:int;
        var j:int;

        var numCols:int;
        var uid:String;

        var curX:Number;

        var rowCount:int = rowInfo.length;
        var columnCount:int = listItems[0].length;
        var cursorPos:CursorBookmark;

        var moveBlockDistance:Number = 0;
        
		var c:DataGridColumn;
		var item:IListItemRenderer;
		var itemSize:Point;
		var data:Object;

		var xx:Number;
		var yy:Number;

        if (scrollUp) // actually, rows move left
        {
            // determine how many columns we're discarding
            var discardCols:int = deltaPos;
     
            // measure how far we have to move by measuring the width of the columns we
            // are discarding
            
            moveBlockDistance = sumColumnWidths(discardCols, true);
            // trace("moveBlockDistance = " + moveBlockDistance);

            //  shift rows leftward and toss the ones going away
            for (i = 0; i < rowCount; i++)
            {
                numCols = listItems[i].length;

                // move the positions of the row, the item renderers for the row,
                // and the indicators for the row
                moveRowHorizontally(i, discardCols, -moveBlockDistance, numCols);
                // move the renderers within the array of rows
                shiftColumns(i, discardCols, numCols);
				truncateRowArray(i);
            }

			// generate replacement columns
            cursorPos = iterator.bookmark;

			var firstNewColumn:int = lastNumberOfColumns - deltaPos;
            curX = listItems[0][firstNewColumn - 1].x + listItems[0][firstNewColumn - 1].width;


			for (i = 0; i < rowCount; i++)
			{
                data = iterator.current;
                iterator.moveNext();
                uid = itemToUID(data);

				xx = curX;
				yy = rowInfo[i].y;
				for (j = firstNewColumn; j < visibleColumns.length; j++)
				{
					c = visibleColumns[j];
					item = setupColumnItemRenderer(c, listContent, i, j, data, uid);
					itemSize = layoutColumnItemRenderer(c, item, xx, yy);
					xx += itemSize.x;
				}
				// toss excess columns
				if (listItems[i].length > visibleColumns.length)
				{
					addToFreeItemRenderers(listItems[i].pop());
				}
			}

            iterator.seek(cursorPos, 0);           
        }
        else
        {
            numCols = listItems[0].length;

            moveBlockDistance = sumColumnWidths(deltaPos, false);

            // shift the renderers and slots in array
            for (i = 0; i < rowCount; i++)
            {
                numCols = listItems[i].length;

                moveRowHorizontally(i, 0, moveBlockDistance, numCols);
				// we add placeholders at the front for new renderers
				addColumnPlaceHolders(i, deltaPos);

            }

            cursorPos = iterator.bookmark;

			for (i = 0; i < rowCount; i++)
			{
                data = iterator.current;
                iterator.moveNext();
                uid = itemToUID(data);

				xx = 0;
				yy = rowInfo[i].y;
				for (j = 0; j < deltaPos; j++)
				{
					c = visibleColumns[j];
					item = setupColumnItemRenderer(c, listContent, i, j, data, uid);
					itemSize = layoutColumnItemRenderer(c, item, xx, yy);
					xx += itemSize.x;
				}
				// toss excess columns
				if (listItems[i].length > visibleColumns.length)
				{
					addToFreeItemRenderers(listItems[i].pop());
				}
			}

            iterator.seek(cursorPos, 0);           
		}

		// force update the header
		header.headerItemsChanged = true;
		header.visibleColumns = visibleColumns;
		header.invalidateDisplayList();
		header.validateNow();

		// draw column lines and backgrounds
		drawLinesAndColumnBackgrounds();
    }        
	
	// if moving left, add up old renderers
	// if moving right, add up new columns
	private function sumColumnWidths(num:int, left:Boolean):Number
	{
		var i:int;
		var value:Number = 0;
		if (left)
		{
			for (i = 0; i < num; i++)
			{
				value += listItems[0][i].width;
			}
		}
		else
			for (i = 0; i < num; i++)
			{
				value += visibleColumns[i].width;
			}

		return value;
	}

	// shift position of renderers on screen
	private function moveRowHorizontally(rowIndex:int, start:int, distance:Number, end:int):void
	{
		for (;start < end; start++)
			listItems[rowIndex][start].x += distance;
	}

	// shift renderer assignments in listItems array
	private function shiftColumns(rowIndex:int, shift:int, numCols:int):void
	{
		var item:IListItemRenderer;

        for (var i:int = 0; i < shift; i++)
		{
			item = listItems[rowIndex].shift();
			if(item)
				addToFreeItemRenderers(item);
		}
	}

	// add places in front of row for new columns
	private function addColumnPlaceHolders(rowIndex:int, count:int):void
	{
		for (var i:int = 0; i < count; i++)
		{
			listItems[rowIndex].unshift(null);
		}
	}

	// remove excess columns
	private function truncateRowArray(rowIndex:int):void
	{
		while (listItems[rowIndex].length > visibleColumns.length)
		{
			var item:IListItemRenderer;
			{
				item = listItems[rowIndex].pop();
				addToFreeItemRenderers(item);
			}
		}
	}
}
}