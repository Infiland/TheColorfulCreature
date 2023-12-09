/// shDeuteranopia
//
//  Deuteranopia color blindness simulation fragment shader.
//
/// GMLscripts.com/license

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const mat4 mDeuteranopia = mat4( 0.43 ,  0.72 , -0.15 ,  0.0 ,
                                 0.34 ,  0.57 ,  0.09 ,  0.0 ,
                                -0.02 ,  0.03 ,  1.00 ,  0.0 ,
                                 0.0  ,  0.0  ,  0.0  ,  1.0 );

void main()
{
    gl_FragColor = (v_vColour * texture2D(gm_BaseTexture, v_vTexcoord)) * mDeuteranopia;
}
