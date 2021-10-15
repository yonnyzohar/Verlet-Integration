package {
	import flash.geom.*;
	import flash.display.*;
	import flash.events.*;

	public class Triangle {

	
		public function Triangle() {
			
		

		}



		public static function rasterize(p0:Object, p1:Object, p2:Object, bd:BitmapData, src:BitmapData):void
		{
			var points: Array = [p0, p1, p2];
			sortPoints(points);
			fillTriangle(points, bd, src);
		}

		private static function sortPoints(points:Array): void {
			var aux: Object;
			//if point 0 is lower than point 1, then point 1 needs to be 0
			if (points[0].y > points[1].y) {
				aux = points[0];
				points[0] = points[1];
				points[1] = aux;
			}
			//if point 0 is lower than point 2, then point 2 needs to be 0
			if (points[0].y > points[2].y) {
				aux = points[0];
				points[0] = points[2];
				points[2] = aux;
			}
			//if point 1 is lower than point 2, then point 2 needs to be 1
			if (points[1].y > points[2].y) {
				aux = points[1];
				points[1] = points[2];
				points[2] = aux;
			}
		}

		private static function fillTriangle(points:Array, bd:BitmapData, src:BitmapData): void {

			var texW:Number = src.width;
			var texH:Number = src.height;
			
			var p0x: Number = points[0].x;
			var p0y: Number = points[0].y;

			var p0u: Number = points[0].u;
			var p0v: Number = points[0].v;

			var p1x: Number = points[1].x;
			var p1y: Number = points[1].y;

			var p1u: Number = points[1].u;
			var p1v: Number = points[1].v;

			var p2x: Number = points[2].x;
			var p2y: Number = points[2].y;

			var p2u: Number = points[2].u;
			var p2v: Number = points[2].v;
			
			
			

			//each triangle is split in 2 to make calculations easier.
			//first we do the top part, then the bottom part
			if (p0y < p1y) {


				var side1Width: Number = (p1x - p0x);
				var side1Height: Number = (p1y - p0y);

				//slope from top to first side - when y moves by 1, how much does x move by?
				var slope1: Number = side1Width / side1Height;

				var side2Width: Number = (p2x - p0x);
				var side2Height: Number = (p2y - p0y);
				//slope from top to second side - when y moves by 1, how much does x move by?
				var slope2: Number = side2Width / side2Height;


				//u length - the width of change in percentage on the u (x) axis
				var side1uWidth: Number = (p1u - p0u);
				//v height - the height of change in percentage on the v (y) axis
				var side1vHeight: Number = (p1v - p0v);

				//u length - the width of change in percentage on the u (x) axis
				var side2uWidth: Number = (p2u - p0u);

				//u length - the width of change in percentage on the u (x) axis
				var side2vHeight: Number = (p2v - p0v);

				for (var i: int = 0; i <= side1Height; i++) {

					var _y: Number = p0y + i; // when y grows by 1
					var startX: int = p0x + i * slope1; // start x grows by initial x + (i * slope1)
					var endX: int = p0x + i * slope2; // end x grows by initial x + (i * slope2)

					//u start and v start
					var side1Per:Number = (i / side1Height);
					var startU: Number = p0u + (side1Per * side1uWidth);
					var startV: Number = p0v + (side1Per * side1vHeight);

					//u end and v end
					var side2Per:Number = i / side2Height;
					var endU: Number = p0u + (side2Per * side2uWidth);
					var endV: Number = p0v + (side2Per * side2vHeight);


					//if start is greater than and, swap the,
					if (startX > endX) {
						var aux: Number = startX;
						startX = endX;
						endX = aux;

						//and also swap uv
						aux = startU;
						startU = endU;
						endU = aux;

						aux = startV;
						startV = endV;
						endV = aux;
					}


					if (endX > startX) {

						var triangleCurrWidth: Number = endX - startX;

						//this is the initial u which we will increment
						var u: Number = startU * texW;

						//this is the increment step on the u axis
						var ustep: Number = ((endU - startU) / triangleCurrWidth) * texW;

						//this is the initial v which we will increment
						var v: Number = startV * texH;
						//this is the increment step on the v axis
						var vstep: Number = ((endV - startV) / triangleCurrWidth) * texH;


						for (var j: int = 0; j <= triangleCurrWidth; j++) {
							var _x: int = startX + j;

							u += ustep;
							v += vstep;

							var pixel: uint = src.getPixel(u, v);
							bd.setPixel(_x, _y, pixel);
							//g.lineTo(_x, _y);
						}
					}
				}
			}

			////
			//bottom part of the triangle
			if (p1y < p2y) {

				var side3Width: Number = (p2x - p1x);
				var side3Height: Number = (p2y - p1y);
				//slope from top to first side - when y moves by 1, how much does x move by?
				var slope3: Number = side3Width / side3Height;

				var side2Width: Number = (p2x - p0x);
				var side2Height: Number = (p2y - p0y);
				//slope from top to second side - when y moves by 1, how much does x move by?
				var slope2: Number = side2Width / side2Height;

				//this is the middle point on slope 2
				//the slope means - when we move y by 1, how much does x move by?
				//so if we start at the bottom and decrease the side3Height * the slope of side 2 we will get the start point
				var midPointSlope2: Number = p2x - (side3Height * slope2);
				

				//u length - the width of change in percentage on the u (x) axis
				var side3uWidth: Number = (p2u - p1u);
				//v height - the height of change in percentage on the v (y) axis
				var side3vHeight: Number = (p2v - p1v);

				//u length - the width of change in percentage on the u (x) axis
				var side2uWidth: Number = (p2u - p0u);

				//u length - the width of change in percentage on the u (x) axis
				var side2vHeight: Number = (p2v - p0v);

				for (var i: int = 0; i <= side3Height; i++) {
					var startX: int = p1x + i * slope3;
					var endX: int = midPointSlope2 + i * slope2;
					var _y: Number = p1y + i;

					//u start and v start
					var side3Per:Number = (i / side3Height);
					var startU: Number = p1u + (side3Per * side3uWidth);
					var startV: Number = p1v + (side3Per * side3vHeight);

					//u nd and v end
					var side2Per:Number = (_y - p0y) / side2Height;
					var endU: Number = p0u + (side2Per * side2uWidth);
					var endV: Number = p0v + (side2Per * side2vHeight);



					if (startX > endX) {
						var aux: Number = startX;
						startX = endX;
						endX = aux;

						//and also swap uv
						aux = startU;
						startU = endU;
						endU = aux;

						aux = startV;
						startV = endV;
						endV = aux;
					}


					if (endX > startX) {
						var triangleCurrWidth: Number = endX - startX;

						var u: Number = startU * texW;
						//this is the increment on the u axis
						var ustep: Number = ((endU - startU) / triangleCurrWidth) * texW;
						var v: Number = startV * texH;
						//this is the increment on the v axis
						var vstep: Number = ((endV - startV) / triangleCurrWidth) * texH;

						for (var j: int = 0; j <= triangleCurrWidth; j++) {
							var _x: int = j + startX;
							u += ustep;
							v += vstep;

							var pixel: uint = src.getPixel(u, v);
							bd.setPixel(_x, _y, pixel);
						}
					}
				}

			}
		}

	}

}