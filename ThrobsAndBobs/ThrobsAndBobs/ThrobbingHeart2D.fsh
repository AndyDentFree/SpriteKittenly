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
    vec2 p =  v_tex_coord; // (2.0 * gl_FragCoord - u_sprite_size.xy)/min(u_sprite_size.y,u_sprite_size.x);

    // background color
    vec3 bcol = vec3(1.0,0.8,0.7-0.07*p.y)*(1.0-0.25*length(p));

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
    // FROM evernote
    // float a = atan(p.x,p.y)/3.141593;
    // float r = length(p);
    // float h = abs(a);
    // float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);
    float a = atan(p.x,p.y)/3.141593;
    float r = length(p);
    float h = abs(a);
    float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);


    // color
    // FROM evernote
    //float f = step(r,d) * pow(1.0-r/d,0.25);
    //gl_FragColor = vec4(f,0.0,0.0,1.0);

    // from site
    float s = 0.75 + 0.75*p.x;
    s *= 1.0-0.4*r;
    s = 0.3 + 0.7*s;
    s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
    vec3 hcol = vec3(1.0,0.5*r,0.3)*s;

    vec3 col = mix( bcol, hcol, smoothstep( -0.01, 0.01, d-r) );
    gl_FragColor = vec4(col,1.0);
}
