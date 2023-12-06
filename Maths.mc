import Toybox.Lang;
import Toybox.Math;

module Util {

	module Maths {
		function uniformRand(low as Lang.Number, high as Lang.Number) as Lang.Number {
			var range = high-low+1;
			var limit = 0x7FFFFFFF - 0x7FFFFFFF%range;
			var r = 0;
			do {
				r = Math.rand();
			} while (r >= limit);
			return low + r % range;
		}

		function distanceOnLine(slope as Lang.Numeric, distance as Lang.Numeric, x as Lang.Number, y as Lang.Number, yIntercept as Lang.Numeric) as Lang.Array<Lang.Numeric>{
			var slopesqr = Math.pow(slope, 2);
			var r = Math.pow(distance, 2);
			var eq1 = (-Math.pow(yIntercept, 2)-2*yIntercept*slope*x+2*yIntercept*y-slopesqr*Math.pow(x, 2)+(r==0?1:r)*slopesqr+2*slope*x*y-Math.pow(y, 2)+r);
			var eq2 = (Math.pow(slope, 4)+2*slopesqr+1);
			var eq3 = (-yIntercept*slope+slope*y+x);
			var eq4 = (slopesqr+1);
			var eq5 = Math.sqrt(eq1/eq2);
			var eq6 = eq3/eq4;
			return [eq5+eq6, -eq5+eq6];
		}
	}


}