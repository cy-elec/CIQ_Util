import Toybox.Lang;

module Util {
	
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
}