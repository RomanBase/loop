#version 460 core
#include <flutter/runtime_effect.glsl>

uniform sampler2D u_Texture;    // The input texture.
uniform vec4 u_Color;



out vec4 fragColor;

void main() {
    vec2 v_TexCoordinate = FlutterFragCoord().xy;

    fragColor = texture2D(u_Texture, v_TexCoordinate) * u_Color;
}


