/**
 * Javascript Plasma.
 * Code by d23, 2008
 */
Plasma = function() {};
Plasma.prototype.sinTable = [];
Plasma.prototype.colorTable = [];
Plasma.prototype.cells = [];
Plasma.prototype.p = [];
Plasma.prototype.o = [];
Plasma.prototype.size=32;
Plasma.prototype.fsin=function(v) { return this.sinTable[v &255]; }
Plasma.prototype.fcol=function(v) { return this.colorTable[v &255]; }
/* Generate table matrix */
Plasma.prototype.createMatrix = function(el) { var tbody = el.appendChild(document.createElement('table')).appendChild(document.createElement('tbody')); for(x=0; x < this.size; x++) { var row = tbody.appendChild(document.createElement('tr')); this.cells[x] = []; for(y=0; y < this.size ; y++) this.cells[x][y] = row.appendChild(document.createElement('td')) /*.id= "x"+x+"y"+y*/; } }
/* Generate sine table */
Plasma.prototype.createSin 	 = function() { var c =  2 * Math.PI / 256; for(var i = 0; i < 256; i++) this.sinTable[i] = Math.round(Math.sin(c * i)* 127 + 128);	}
/* Generate color table */
Plasma.prototype.createColor  = function() { for(var i = 0; i < 256; i++) this.colorTable[i] = '#'+toHex(this.fsin(i*4))+toHex(this.fsin(i*4+64))+toHex(this.fsin(i*4+100)); }
/* Seed the plasma */
Plasma.prototype.seed  = function() { for(var i=0; i < 6; i++) this.o[i] = rnd(12); }
/* Initialize the plasma */
Plasma.prototype.init  = function(el) { this.createSin(); this.createColor(); this.createMatrix(el); for(var i=0; i < 4; i++) this.p[i] = rnd(255); this.seed(); }
/* Plasma function */
Plasma.prototype.render = function() { var tp = []; tp[2] = this.p[2]; tp[3] = this.p[3]; this.p[0] += this.o[4]; this.p[2] += this.o[5];for(x=0; x < this.size; x++) { tp[0] = this.p[0]; tp[1] = this.p[1]; tp[2] += this.o[2];tp[3] += this.o[3]; for(y = 0; y < this.size; y++) /*$('x'+x+'y'+y)*/ this.cells[x][y].style.background = this.fcol( (this.fsin(tp[0] += this.o[0]) + this.fsin(tp[1] += this.o[1]) + this.fsin(tp[2]) + this.fsin(tp[3]) ) >> 2 ); } }
