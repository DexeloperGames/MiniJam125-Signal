
vec2 cexp(vec2 complex){
	return vec2(cos(complex.y),sin(complex.y))*exp(complex.x);
}

vec2 cmult(vec2 left, vec2 right){
	return vec2(left.x*right.x-left.y*right.y,left.x*right.y+left.y*right.x);
}