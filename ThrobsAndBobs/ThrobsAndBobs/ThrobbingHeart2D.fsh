// Shader from https://www.shadertoy.com/view/XsfGRn
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Author comment - I designed the polynomial by hand to give me this shape

/**
 Notes on porting, the original was rendering in a 1280 x 720 window so some size calcs may have been related to that
 
 ShaderToy to SKSShader variables
 iResolution -> u_sprite_size
 GlobalTime -> u_time
 fragColor -> gl_FragColor
 */
void main(void)
{
    vec2 p =  v_tex_coord;

    // animate
    float tt = mod(u_time, 1.5)/1.5;
    float ss = pow(tt,.2)*0.5 + 0.5;
    ss -= ss*0.2*sin(tt*6.2831*5.0)*exp(-tt*6.0);
    // original p *= vec2(0.5,1.5) + ss*vec2(0.5,-0.5);
    p.y -= 0.5;
    p.x -= 0.5;  // added to offset being based on v_tex_coord

    // Get the shape drawing centred and a bit smaller than the frame FIRST
    // then add in the animation bounce with the ss multiplier
    p *= vec2(1.0, 2.5) + ss*vec2(1.0,-0.8);  // offset for v_tex_coord used for p
    p.y -= 0.25;

    // shape
    float a = atan(p.x,p.y)/3.141593;
    float r = length(p);
    float h = abs(a);
    float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);


    // color
    float s = 0.75 + 0.75*p.x;
    s *= 1.0-0.4*r;
    s = 0.3 + 0.7*s;
    s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
    
    /*
    // opaque blending heart with a solid background gradient
    vec3 hcol = vec3(1.0,0.5*r,0.3)*s;
    // background color gradient
    vec3 bcol =  vec3(1.0,0.8,0.7-0.07*p.y)*(1.0-0.25*length(p)); // original gradient
    vec3 col = mix( bcol, hcol, smoothstep( -0.01, 0.01, d-r) );
    gl_FragColor = vec4(col,1.0);
     */
    
    // blending heart with alpha
    vec4 bcol = vec4(0.0, 0.0, 0.0, 0.0);
    // current color we don't want because pulled from our node, just be transparent = texture2D(u_texture, v_tex_coord);
    vec3 scol = vec3(1.0,0.5*r,0.3)*s;
    vec4 hcol = vec4(scol,1.0);
    gl_FragColor = mix( bcol, hcol, smoothstep( -0.01, 0.01, d-r) );
}
