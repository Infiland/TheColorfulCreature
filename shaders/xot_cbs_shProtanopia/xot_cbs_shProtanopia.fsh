/// shProtanopia
//
//  Protanopia color blindness simulation fragment shader.
//
/// GMLscripts.com/license

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const mat4 mProtanopia = mat4( 0.20 ,  0.99 , -0.19 ,  0.0 ,
                               0.16 ,  0.79 ,  0.04 ,  0.0 ,
                               0.01 , -0.01 ,  1.00 ,  0.0 ,
                               0.0  ,  0.0  ,  0.0  ,  1.0 );

void main()
{
    gl_FragColor = (v_vColour * texture2D(gm_BaseTexture, v_vTexcoord)) * mProtanopia;
}

