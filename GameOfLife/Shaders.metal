//
//  Shaders.metal
//  GameOfLife
//
//  Created by Chris Davis on 27/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float4 life = float4(1.0, 0.0, 0.0, 1.0);
constant float4 death = float4(0.0, 0.0, 0.0, 1.0);

float rand(int x, int y, int z) {
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

kernel void SeedLife(texture2d<float, access::read_write> inTexture [[texture(0)]],
                     const device int &randomNumber [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    
    float4 color;
    if (rand(gid.y,randomNumber,gid.x) > 0.5) {
        color = life;
    } else {
        color = death;
    }

    inTexture.write(color, gid);
    
    // Draw a glider
//    inTexture.write(color, uint2( 10 + 1, 10 + 3));
//    inTexture.write(color, uint2( 10 + 2, 10 + 4));
//    inTexture.write(color, uint2( 10 + 3, 10 + 2));
//    inTexture.write(color, uint2( 10 + 3, 10 + 3));
//    inTexture.write(color, uint2( 10 + 3, 10 + 4));

}

kernel void GameOfLife(texture2d<float, access::read> inTexture [[texture(0)]],
                       texture2d<float, access::write> outTexture [[texture(1)]],
                       uint2 gid [[thread_position_in_grid]]) {
    
    
    float4 color = inTexture.read(gid);
    int current = int(inTexture.read(gid).r);
    
    int sum = 0;
    sum += int(inTexture.read( gid + uint2( 1, 0)).r); //right
    sum += int(inTexture.read( gid + uint2( 0, 1)).r); //bottom
    sum += int(inTexture.read( gid - uint2( 1, 0)).r); //left
    sum += int(inTexture.read( gid - uint2( 0, 1)).r); //top
    sum += int(inTexture.read( gid - uint2( 1, 1)).r); //top left
    sum += int(inTexture.read( gid + uint2( 1,-1)).r); //top right
    sum += int(inTexture.read( gid + uint2(-1, 1)).r); //bottom left
    sum += int(inTexture.read( gid + uint2( 1, 1)).r); //bottom right
    
    if (current == 1 && sum < 2) { // loneliness
        color = death;
    } else  if (current == 1 && (sum == 2 || sum == 3)) {
        color = life;
    } else if (current == 1 && sum > 3) { // overpopulation
        color = death;
    } else if (current == 0 && sum == 3) { // birth
        color = life;
    } else {
        // same
    }

    outTexture.write(color, gid);
}
