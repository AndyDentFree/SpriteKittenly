
precision highp float;

void main() {
    // get the color of the current pixel
    vec4 current_color = texture2D(u_texture, v_tex_coord);

    // if the current color is not transparent
    if (current_color.a > 0.0) {
        // mix the first color with the second color by however far we are from the bottom,
        // multiplying by this pixel's alpha (to avoid a hard edge) and also
        // multiplying by the node alpha so we can fade in or out
        vec4 new_color = mix(u_second_color, u_first_color, v_tex_coord.y);
        gl_FragColor = vec4(mix(current_color, new_color, new_color.a)) * current_color.a * v_color_mix.a;
    } else {
        // use the current (transparent) color
        gl_FragColor = current_color;
    }
}
