// ThrobbingDisc draws a circle which varies in color and diameter
// original from https://www.shadertoy.com/view/XtBcWh
void main(void)
{
    vec2 uv = v_tex_coord;  // ShaderToy fragCoord.xy / iResolution.y
    uv = uv*2.0-1.0;
    float Length = 1.0 - smoothstep(length(uv),0.0,0.4) / max(0.000000001, abs( sin(u_beat*u_time)));  // multiply u_time to get faster beat
    float sut = abs(sin(u_time));
    //vec3 scol = vec3(0.9, 0.9, 0.9); // fixed grey color
    vec3 scol = vec3(sut, sut, 1.0); //original cycled color as shades of Blue
    vec4 hcol = vec4(scol*Length, 0.0);  // use 1.0 for the last, Alpha, param here to get solid block for debugging
    gl_FragColor = hcol;  // vec4(0.7, .07, 0.7, 1.0);  solid magenta block
}
