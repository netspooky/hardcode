function Circle(x,y,res,xsize)
{
	this.dots = new Array();
	this.rotateRelative = FrotateRelative;
	this.setColor = FsetColor;
	this.setSize = FsetSize;
	this.setCenter = FsetCenter;
	this.count = res;
	this.size = xsize;
	this.offset = 0;
	this.step = 360.0 / this.count;
	this.x = x;
	this.y = y;
	for(var i = 0; i<this.count;i++){
		var tx = Math.cos(degreeToRadian(i * this.step)) * this.size + x;
		var ty = Math.sin(degreeToRadian(i * this.step)) * this.size + y;
		var something = produceSomethingAdvanced("text", "goat.cx", tx,ty);
		this.dots[i] = new Point(something, tx, ty);
		appendSomething(something);
	}

	
	function FrotateRelative(degrees){
		for(var i = 0; i<this.count;i++){
			this.offset = this.offset + degrees;
			var tx = Math.cos(degreeToRadian(i * this.step + this.offset)) * this.size + this.x;
			var ty = Math.sin(degreeToRadian(i * this.step + this.offset)) * this.size + this.y;
			var something = this.dots[i].something;
			setPosition(something, tx, ty);
		}
	}

	function  FsetColor(r,g,b){
		for(var i = 0; i<this.count;i++){
			var something = this.dots[i].something;
			setColor(something, r, g, b);
		}
	}

	function  FsetSize(size){
		this.size = size;
		for(var i = 0; i<this.count;i++){
			var tx = Math.cos(degreeToRadian(i * this.step)) * this.size + x;
			var ty = Math.sin(degreeToRadian(i * this.step)) * this.size + y;
			setPosition(this.dots[i].something, tx, ty);
		}
	}
	
	function  FsetCenter(x,y){
		this.x = x;
		this.y = y;
		for(var i = 0; i<this.count;i++){
			var tx = Math.cos(degreeToRadian(i * this.step)) * this.size + x;
			var ty = Math.sin(degreeToRadian(i * this.step)) * this.size + y;
			setPosition(this.dots[i].something, tx, ty);
		}
	}
}
