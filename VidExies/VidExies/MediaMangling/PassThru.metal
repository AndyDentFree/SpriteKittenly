//
//  PassThru.metal
//  VidExies
//
//  Created by Andrew Dent on 8/7/2025.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_passthrough(uint vertexID [[vertex_id]]) {
    float4 positions[4] = {
        float4(-1, -1, 0, 1),
        float4( 1, -1, 0, 1),
        float4(-1,  1, 0, 1),
        float4( 1,  1, 0, 1),
    };
    float2 uvs[4] = {
        float2(0, 1),
        float2(1, 1),
        float2(0, 0),
        float2(1, 0),
    };
    VertexOut out;
    out.position = positions[vertexID];
    out.texCoord = uvs[vertexID];
    return out;
}

fragment float4 fragment_passthrough(VertexOut in [[stage_in]],
                                     texture2d<float> tex [[texture(0)]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    return tex.sample(s, in.texCoord);
}
