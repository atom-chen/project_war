#ifdef OPENGL_ES
precision mediump vec2;
precision mediump float;
#endif

// Attributes
attribute vec3 a_position;
attribute vec2 a_texCoord;

// Varyings
#ifdef GL_ES
varying vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif

void main()
{
    gl_Position = CC_PMatrix * vec4(a_position, 1.0);
    v_texCoord = a_texCoord;
}
