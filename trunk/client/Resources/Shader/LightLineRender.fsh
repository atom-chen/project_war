uniform float offset;

// Varyings
#ifdef GL_ES
varying vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif

void main()
{
	float nX = v_texCoord.x;
	float nY = v_texCoord.y - offset;
	if (nY <= 0.0)
	{
		nY = v_texCoord.y + 1.0 - offset;
	}
    
    vec4 col = texture2D(CC_Texture0, vec2(nX, nY));
    
	gl_FragColor = col;

}