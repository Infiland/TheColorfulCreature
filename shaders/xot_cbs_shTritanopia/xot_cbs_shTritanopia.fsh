/// shTritanopia
//
//  Tritanopia color blindness simulation fragment shader.
//
/// GMLscripts.com/license

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const mat4 mTritanopia = mat4( 0.97 ,  0.11 , -0.08 ,  0.0 ,
                               0.02 ,  0.82 ,  0.16 ,  0.0 ,
                              -0.06 ,  0.88 ,  0.18 ,  0.0 ,
                               0.0  ,  0.0  ,  0.0  ,  1.0 );

void main()
{
    gl_FragColor = (v_vColour * texture2D(gm_BaseTexture, v_vTexcoord)) * mTritanopia;
}

