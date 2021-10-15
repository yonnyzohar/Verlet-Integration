package {
	import flash.geom.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;


	public class Main extends MovieClip {

		var pointsMatrix: Array = [];
		var points: Array = [];
		var sticks: Array = [];
		var applyWind: Boolean = true;

		var triangles: Array = [];
		var renderLines: Boolean = true;
		var linesColor: uint;
		var renderBitmap: Boolean = false;
		var currPoint: Object = null;

		var size: Number = 10;
		var num_rows: int = 20;
		var num_cols: int = 21;

		var bd: BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
		var bmp: Bitmap = new Bitmap(bd);
		var mona: Mona = new Mona();
		var texW: Number = mona.width;
		var texH: Number = mona.height;
		var verletEngine: VerletEngine;
		
		var mc: MovieClip = new MovieClip();
		var g:Graphics = mc.graphics;



		public function Main() {
			stage.addChild(bmp);
			bd.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0xffffff);
			stage.addChild(mc);
			
			for (var row: int = 0; row < num_rows; row++) {
				pointsMatrix[row] = [];
				for (var col: int = 0; col < num_cols; col++) {
					var p: Object = {
						x: (col * size) + 200,
						y: (row * size),
						wind: new Point(Math.random() * 5 - 3, Math.random() * 5 - 3),
						u: Number(Number(col) / Number(num_cols)),
						v: Number(Number(row) / Number(num_rows))

					};
					p.prevX = p.x + p.wind.x;
					p.prevY = p.y + p.wind.y;
					pointsMatrix[row][col] = p;
					points.push(p);

					if (row == 0) {
						if (col % 5 == 0) {
							p.pinned = true;
						}
					}
				}
			}

			for (row = 0; row < num_rows; row++) {
				for (col = 0; col < num_cols; col++) {
					var topLeft: Object = pointsMatrix[row][col];

					if (pointsMatrix[row] && pointsMatrix[row][col + 1]) {
						var topRight: Object = pointsMatrix[row][col + 1];
						sticks.push({
							p1: topLeft,
							p2: topRight,
							distance: distance(topLeft, topRight)
						});

						if (pointsMatrix[row + 1] && pointsMatrix[row + 1][col]) {
							var btmLeft: Object = pointsMatrix[row + 1][col];
							sticks.push({
								p1: topLeft,
								p2: btmLeft,
								distance: distance(topLeft, btmLeft)
							});

							var btmRight: Object = pointsMatrix[row + 1][col + 1];

							//if (col == num_cols - 2) {
							sticks.push({
								p1: topRight,
								p2: btmRight,
								distance: distance(topRight, btmRight)
							});
							//}

							triangles.push({
								a: btmLeft,
								b: topLeft,
								c: topRight
							});
							triangles.push({
								a: btmLeft,
								b: topRight,
								c: btmRight
							});
						}
					}
				}
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(Event.ENTER_FRAME, loop);


			verletEngine = new VerletEngine(points, sticks);
			verletEngine.gravity = .5;
			verletEngine.friction = 0.99;
			verletEngine.bounce = 0.9; //when hitting the edges we multiply values by bounce to make it lose power




		}


		function keyDownHandler(event: KeyboardEvent): void {
			if (event.keyCode == Keyboard.ENTER) {
				renderBitmap = !renderBitmap;
			}
			if (event.keyCode == Keyboard.SPACE) {
				renderLines = !renderLines;
			}
			if (event.keyCode == 49) {
				for (var i: int = 0; i < num_cols; i++) {
					if (pointsMatrix[0][i].pinned) {
						pointsMatrix[0][i].pinned = false;
						break;
					}
				}
			}

		}

		function getClosestPoint(_x: Number, _y: Number): Object {
			var minDist: Number = Number.MAX_VALUE;
			var cp: Object;

			for (var i: int = 0; i < points.length; i++) {
				var p: Object = points[i];
				var xDist: Number = p.x - _x;
				var yDist: Number = p.y - _y;
				var distance: Number = Math.sqrt(xDist * xDist + yDist * yDist);
				if (distance < minDist) {
					minDist = distance;
					cp = p;
				}

			}
			return cp;
		}

		function onDown(e: MouseEvent): void {
			currPoint = getClosestPoint(stage.mouseX, stage.mouseY);

		}

		function onUp(e: MouseEvent): void {
			currPoint = null;
		}





		function distance(p1: Object, p2: Object): Number {
			var xDist: Number = p2.x - p1.x;
			var yDist: Number = p2.y - p1.y;
			return Math.sqrt(xDist * xDist + yDist * yDist);
		}

		function loop(e: Event): void {

			bd.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0xffffff);

			if (renderBitmap) {
				linesColor = 0xffffff;

			} else {
				linesColor = 0x000000;
			}


			if (currPoint) {
				currPoint.x = stage.mouseX;
				currPoint.y = stage.mouseY;
			}

			g.clear();
			verletEngine.updatePoints();
			//for (var i: int = 0; i < 5; i++) {
			verletEngine.updateSticks();
			verletEngine.constrainPoints(0, 0, stage.stageWidth, stage.stageHeight);
			renderTriangles();
			//}
			if (!renderLines) {
				return;
			}
			verletEngine.renderSticks(g, linesColor);

		}

		function renderTriangles(): void {
			if (!renderBitmap) {
				return;
			}
			for (var i: int = 0; i < triangles.length; i++) {
				var t: Object = triangles[i];
				Triangle.rasterize(t.a, t.b, t.c, bd, mona);
			}
		}


	}

}