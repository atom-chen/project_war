#ifdef OPENGL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
uniform float fHave;
uniform float fWill;

const float fApWill = 0.5;

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 col = texture2D(CC_Texture0, v_texCoord );
	float fX = v_texCoord.x;
	float fY = v_texCoord.y;
	
	if( col.a < 0.001 )
    {
    	gl_FragColor = col;
    	return;
    }
    
    if(fX >= fHave)
    {
    	col = vec4( 0.001, 0.001, 0.001, 0.001 );
    }
    else if( fX >= fWill )
    {
    	col.rgb -= vec3(0.2, 0.2, 0.2);
    	//col.a = fApWill;
    }
    
	gl_FragColor = col;
}