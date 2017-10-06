uniform float fHave;
uniform float fWill;

const vec3 blackNo = vec3(0.75);
const vec3 blackWill = vec3(0.4);

// Varyings
#ifdef GL_ES
varying vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif

vec4 makeBlack(vec4 col, float fX, float fY, float fPer, vec3 vecBlack)
{
	float b = 0.5 + 0.5/tan(radians(360.0*fPer));
    float k = 1.0 - b/0.5;
    if (fPer < 0.5)
    {
    	if (fX >= 0.5 && fY <= k*fX + b)
    	{
    		col.rgb += vecBlack;
    	}
    }
    else if ((fPer == 0.5 && fX >= 0.5) || fPer == 1.0)
    {
    	col.rgb += vecBlack;
    }
    else if (fPer > 0.5)
    {
    	if (fX >= 0.5)
    	{
    		col.rgb += vecBlack;
    	}
    	else if (fY >= k*fX + b)
    	{
    		col.rgb += vecBlack;
    	}
    }
    return col;
}

void main()
{
	vec4 col = texture2D(CC_Texture0, v_texCoord);
	float fX = v_texCoord.x;
	float fY = v_texCoord.y;
	
	if (col.a < 0.001)
    {
    	gl_FragColor = col;
    	return;
    }
    
    col.rgb = col.rgb - blackNo;
    
    // will
    col = makeBlack(col, fX, fY, fWill, blackNo - blackWill);
    
    // have
    col = makeBlack(col, fX, fY, fHave, blackWill);
    
	gl_FragColor = col;
}