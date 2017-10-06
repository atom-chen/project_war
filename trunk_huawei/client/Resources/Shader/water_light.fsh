#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
uniform float timer;
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;
const vec3 nLightPlus = vec3(0.2, 0.2, 0.2);
void main() 
{
	float nX = v_texCoord.x + sin(timer+v_texCoord.x*10.0)*0.01;
    float nY = v_texCoord.y + cos(timer+v_texCoord.y*10.0)*0.01;
	vec4 col = texture2D(CC_Texture0, vec2(nX, nY));
	
	gl_FragColor = col;
	return;
}