#version 430

//note that this only effects what the parameters to glDispatchCompute are - by using gl_GlobalInvocationID, you don't need to worry what any of those numbers are
layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;    //specifies the workgroup size

uniform layout(rgba8) image3D previous;       //now-current values of the block
uniform layout(r8ui) uimage3D previous_mask;  //now-current values of the mask

uniform layout(rgba8) image3D current;        //values of the block after the update
uniform layout(r8ui) uimage3D current_mask;   //values of the mask after the update

uniform bool respect_mask;         //when clearing, should you touch the masked cells?
//true means you will not touch the masked cells, false means you will indeed clear all

void main()
{
  uvec4 pmask = imageLoad(previous_mask, ivec3(gl_GlobalInvocationID.xyz));  //existing mask value (previous_mask = 0?)
  vec4 pcol = imageLoad(previous, ivec3(gl_GlobalInvocationID.xyz));                 //existing color value (what is the previous color?)

  if((pmask.r > 0) && respect_mask) //the cell was masked
  {
    imageStore(current, ivec3(gl_GlobalInvocationID.xyz), pcol);  //color takes on previous color
    imageStore(current_mask, ivec3(gl_GlobalInvocationID.xyz), pmask);  //mask is set true
  }
  else
  {
    imageStore(current, ivec3(gl_GlobalInvocationID.xyz), vec4(0));
    imageStore(current_mask, ivec3(gl_GlobalInvocationID.xyz), pmask);
  }
}
