import std.stdio;

class Polygon {	
	int width,height;

	this() {
		this.width = 0;
		this.height = 0;
	}
	~this(){
		this.width = 0;
		this.height = 0;
	}
	
	void set_values(int a, int b) {
		this.width = a;
		this.height = b;
	}

	int area() {
		return 0;
	}

	int sides() {
		return 0;
	}
}

class Rectangle : Polygon {
	this() {

	}

	~this() {

	}

	override int area() {
		return this.width * this.height;
	}

	override int sides() {
		return 4;
	}
}

class Triangle : Polygon {
	this() {

	}

	~this() {

	}

	override int area() {
		return this.width * this.height / 2;
	}

	override int sides() {
		return 3;
	}
}

void printArea(Polygon p) {
	p.area().writeln;
}

void printSides(Polygon p) {
	p.sides().writeln;
}

int main(string[] argv) {
	auto a = new Polygon();
	auto b = new Rectangle();
	auto c = new Triangle();
	a.set_values(4, 5);
	b.set_values(4, 5);
	c.set_values(4, 5);
	printArea(a);
	printSides(a);
	printArea(b);
	printArea(c);
	return 0;
}

