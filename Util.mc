import Toybox.Lang;
import Toybox.Math;
import Toybox.Graphics;

module Util {

	module Maths {
		function uniformRand(low as Number, high as Number) as Number {
			var range = high-low+1;
			var limit = 0x7FFFFFFF - 0x7FFFFFFF%range;
			var r = 0;
			do {
				r = Math.rand();
			} while (r >= limit);
			return low + r % range;
		}
	}

	module Arrays {
		function max(array as Lang.Array<Lang.Numeric>) as Lang.Numeric {
			var array_max = 0;
			for (var i=0; i<array.size(); i++) {
				if (array[i] > array_max) {
					array_max = array[i];
				}
			}
			return array_max;
		}
		function extremum(array as Lang.Array<Lang.Numeric>) as Lang.Numeric {
			var array_max = 0;
			for (var i=0; i<array.size(); i++) {
				if (array_max < 0) {
					if (array[i] < array_max || array[i] > -array_max) {
						array_max = array[i];
					}
				}
				else if (array_max >= 0) {
					if (array[i] < -array_max || array[i] > array_max) {
						array_max = array[i];
					}
				}
			}
			return array_max;
		}
		function abs(array as Lang.Array<Lang.Numeric>) as Lang.Array<Lang.Numeric> {
			var ret_array = new [array.size()];
			for (var i=0; i<array.size(); i++) {
				ret_array[i] = array[i].abs();
			}
			return ret_array;
		}
	}

	module Graphs {
		enum Quadrants {
			QUADRANT_1 = 1,
			QUADRANT_2 = 2,
			QUADRANT_3 = 4,
			QUADRANT_4 = 8,
		}
		typedef QuadrantType as Lang.Number or $.Util.Graphs.Quadrants;
		function drawBarGraph(dc as Dc,
			options as {:x as Lang.Number, :y as Lang.Number, :width as Lang.Number, :height as Lang.Number,
			:foregroundColor as Graphics.ColorType, :shadeColor as Graphics.ColorType, :backgroundColor as Graphics.ColorType, :barPositiveColor as Graphics.ColorType, :barNegativeColor as Graphics.ColorType,
			:quadrants as $.Util.Graphs.QuadrantType, :grid as Lang.Boolean, :gridUnits as Lang.Number,
			:columnWidth as Lang.Number, :columnSpacing as Lang.Number,
			:drawLabels as Lang.Boolean, :labelsDc as Graphics.Dc, :labels as Lang.Array<Lang.String>, :labelsColor as Graphics.ColorType, :unitsColor as Graphics.ColorType, :labelsFont as Graphics.FontType, :drawUnits as Lang.Boolean,
			:noGraph as Lang.Boolean}, data as Lang.Array<Lang.Number>) {
			
			// set all required variables
			var x = options[:x] != null ? options[:x] : dc.getWidth()/4;
			var y = options[:y] != null ? options[:y] : dc.getHeight()-dc.getHeight()/4;
			var width = options[:width] != null ? options[:width] : dc.getWidth()/2;
			var height = options[:height] != null ? options[:height] : dc.getHeight()/2;
			var foregroundColor = options[:foregroundColor] != null ? options[:foregroundColor] : Graphics.COLOR_WHITE;
			var shadeColor = options[:shadeColor] != null ? options[:shadeColor] : Graphics.COLOR_LT_GRAY;
			var backgroundColor = options[:backgroundColor] != null ? options[:backgroundColor] : Graphics.COLOR_TRANSPARENT;
			var barPositiveColor = options[:barPositiveColor] != null ? options[:barPositiveColor] : Graphics.COLOR_WHITE;
			var barNegativeColor = options[:barNegativeColor] != null ? options[:barNegativeColor] : Graphics.COLOR_WHITE;
			var quadrants = options[:quadrants] != null ? options[:quadrants] : $.Util.Graphs.QUADRANT_1;
			var grid = options[:grid] != null ? options[:grid] : false;
			var gridUnits = options[:gridUnits] != null ? options[:gridUnits] : 50;
			var columnWidth = 0;
			var columnSpacing = options[:columnSpacing] != null ? options[:columnSpacing] : 0;

			var drawLabels = options[:drawLabels] != null ? options[:drawLabels] : false;
			var labels =  options[:labels] != null ? options[:labels] : new [0];
			var labelsFont = options[:labelsFont] != null ? options[:labelsFont] : Graphics.FONT_XTINY;
			var drawUnits = options[:drawUnits] != null ? options[:drawUnits] : false;
			var labelsColor = options[:labelsColor] != null ? options[:labelsColor] : Graphics.COLOR_BLUE;
			var unitsColor = options[:unitsColor] != null ? options[:unitsColor] : Graphics.COLOR_DK_GRAY;
			var labelsDc = options[:labelsDc] != null ? options[:labelsDc] : null;

			var noGraph = options[:noGraph] != null ? options[:noGraph] : false;

			if (labelsDc == null) {
				drawUnits = false;
				drawLabels = false;
			}

			if (options[:columnWidth] != null) {
				columnWidth = options[:columnWidth];
			}
			else {
				columnWidth = width/data.size();
				if (columnWidth < 1) {
					columnWidth = 1;
				}
			}

			var maxValue = $.Util.Arrays.extremum(data).abs();
			var scaling = 1d*height/(maxValue>0?maxValue:1);

			// draw grid
			
			for (var i=0, u=0; i<height; i+=scaling*gridUnits, u+=gridUnits) {
				
				if (!noGraph) {
					dc.setColor(shadeColor, backgroundColor);
					if (quadrants & $.Util.Graphs.QUADRANT_1) {
						dc.drawLine(x, y-i, x+width, y-i);
					}
					if (quadrants & $.Util.Graphs.QUADRANT_4) {
						dc.drawLine(x, y+i, x+width, y+i);
					}
				}

				if (drawUnits && u!=0) {
					labelsDc.setColor(unitsColor, backgroundColor);
					if (quadrants & $.Util.Graphs.QUADRANT_1) {
						labelsDc.drawText(x-5, y-i, labelsFont, ""+u, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
					}
					if (quadrants & $.Util.Graphs.QUADRANT_4) {
						labelsDc.drawText(x-5, y+i, labelsFont, "-"+u, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
					}
				}
			}
			
			if (!noGraph) {
				// draw quadrants
				dc.setColor(foregroundColor, backgroundColor);
				dc.drawLine(x-5, y, x+width, y);
				if (quadrants & $.Util.Graphs.QUADRANT_1) {
					dc.drawLine(x, y, x, y-height);
				}
				if (quadrants & $.Util.Graphs.QUADRANT_4) {
					dc.drawLine(x, y, x, y+height);
				}
			}
			for (var i=0; i<data.size(); i++) {
				var cHeight = Math.ceil(scaling*data[i]);
				
				if (!noGraph) {
					if (data[i]>0) {
						dc.setColor(barPositiveColor, backgroundColor);
						dc.fillRectangle(x+columnSpacing+(columnWidth)*i, y-cHeight, columnWidth-columnSpacing, cHeight);
					}
					else {
						dc.setColor(barNegativeColor, backgroundColor);
						dc.fillRectangle(x+columnSpacing+(columnWidth)*i, y, columnWidth-columnSpacing, -cHeight);
					}
				}	
				if (drawLabels) {
					labelsDc.setColor(labelsColor, backgroundColor);
					labelsDc.drawText(x+columnSpacing+(columnWidth)*i+(columnWidth-columnSpacing)/2, y, labelsFont, i<labels.size()?labels[i]:i, Graphics.TEXT_JUSTIFY_CENTER);
				}
			}
		}
	}
}