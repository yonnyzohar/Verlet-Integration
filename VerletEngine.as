package {
	import fl.motion.easing.Back;
	import flash.display.Graphics;

	public class VerletEngine {
		private var points: Array;
		private var sticks: Array;
		private var _friction: Number = 1;
		private var _gravity: Number = 0;
		private var _bounce: Number = 1;
		private var _applyWind: Boolean = false;

		public function VerletEngine(_points: Array, _sticks: Array) {
			// constructor code
			points = _points;
			sticks = _sticks;
		}

		public function set gravity(val: Number): void {
			_gravity = val;
		}

		public function set friction(val: Number): void {
			_friction = val;
		}

		public function set bounce(val: Number): void {
			_bounce = val;
		}

		public function set applyWind(val: Boolean): void {
			_applyWind = val;
		}

		public function updatePoints(): void {
			for (var i: int = 0; i < points.length; i++) {
				var p: Object = points[i];
				if (!p.pinned) {
					var dx: Number = (p.x - p.prevX) * _friction;
					var dy: Number = (p.y - p.prevY) * _friction;
					p.prevX = p.x;
					p.prevY = p.y;

					p.x += dx;
					p.y += dy;

					p.y += _gravity;

					if (_applyWind) {
						if (Math.random() < 0.1) {
							p.x += Math.random() * 2;
							p.y -= Math.random() * 2;
						}
					}

				}
			}
		}


		public function updateSticks(): void {
			for (var i: int = 0; i < sticks.length; i++) {
				var stick: Object = sticks[i];
				var dx: Number = (stick.p2.x - stick.p1.x);
				var dy: Number = (stick.p2.y - stick.p1.y);
				var currDistance: Number = Math.sqrt(dx * dx + dy * dy);
				var difference: Number = stick.distance - currDistance;
				var diffPer: Number = difference / currDistance / 2;

				var offsetX: Number = dx * diffPer;
				var offsetY: Number = dy * diffPer;

				if (!stick.p1.pinned) {
					stick.p1.x -= offsetX;
					stick.p1.y -= offsetY;
				}

				if (!stick.p2.pinned) {
					stick.p2.x += offsetX;
					stick.p2.y += offsetY;
				}
			}

		}


		public function constrainPoints(x: Number, y: Number, w: Number, h: Number): void {
			for (var i: int = 0; i < points.length; i++) {
				var p: Object = points[i];
				var dx: Number = (p.x - p.prevX) * _friction;
				var dy: Number = (p.y - p.prevY) * _friction;

				if (p.x < x) {
					p.x = x;
					p.prevX = p.x + dx * _bounce;

				}
				if (p.x > w) {
					p.x = w;
					p.prevX = p.x + dx * _bounce;
				}

				if (p.y < y) {
					p.y = y;
					p.prevY = p.y + dy * _bounce;
				}

				if (p.y > h) {
					p.y = h;
					p.prevY = p.y + dy * _bounce;
				}
			}
		}


		public function renderSticks(g:Graphics, linesColor:uint): void {

			var i: int = 0;
			/*
	for ( i = 0; i < points.length; i++) {
			var p: Object = points[i];
			g.beginFill(0x000000);
			g.drawCircle(p.x, p.y, 2);
			g.endFill();

	}
	*/
			for (i = 0; i < sticks.length; i++) {
				var stick: Object = sticks[i];
				g.lineStyle(0.1, linesColor);
				g.moveTo(stick.p1.x, stick.p1.y);
				g.lineTo(stick.p2.x, stick.p2.y);
			}
		}






	}

}