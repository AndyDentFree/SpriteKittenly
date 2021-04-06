// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

// draws as ellipse if node is not square
float circle(vec2 _st, float _radius){
    vec2 dist = _st-vec2(0.5);
    return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

float invcircle(vec2 _st, float _radius){
    vec2 dist = _st-vec2(0.5);
    return smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

void main(){
    vec3 color = vec3(invcircle(v_tex_coord,0.9));

    gl_FragColor = vec4( color, 0.1 );
}
