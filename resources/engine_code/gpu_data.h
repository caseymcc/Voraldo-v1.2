#ifndef GPU_DATA
#define GPU_DATA

#include "includes.h"

class GLContainer {
public:
  GLContainer() {}
  ~GLContainer() {}

  // GPU side initialization
  void init() {
    compile_shaders();
    buffer_geometry();
    load_textures();
  }

  // display functions
  bool show_widget = true;
  void display() {
    display_block();
    if (show_widget)
      display_orientation_widget();
  }

  // OpenGL clear color
  glm::vec4 clear_color;

  // screen dimensions
  unsigned int screen_width, screen_height;
  // float theta = -0.7, phi = -0.5;

  // basis vectors
  glm::vec3 basisx = glm::vec3(1., 0., 0.), basisy = glm::vec3(0., 1., 0.),
            basisz = glm::vec3(0., 0., 1.);

  // apply the rotation to the basis vectors about the x and y axes
  void rotate_horizontal(float amnt) {
    basisx = glm::rotate(basisx, amnt, glm::vec3(0, 1, 0));
    basisy = glm::rotate(basisy, amnt, glm::vec3(0, 1, 0));
    basisz = glm::rotate(basisz, amnt, glm::vec3(0, 1, 0));
  }

  void rotate_vertical(float amnt) {
    basisx = glm::rotate(basisx, amnt, glm::vec3(1, 0, 0));
    basisy = glm::rotate(basisy, amnt, glm::vec3(1, 0, 0));
    basisz = glm::rotate(basisz, amnt, glm::vec3(1, 0, 0));
  }

  // settings variables
  glm::vec3 orientation_widget_offset;
  float alpha_correction_power = 2.0;
  int color_temp = 6500;
  int tonemap_mode = 2;

  float scale = 5.;
  int clickndragx = 0;
  int clickndragy = 0;

private:
  bool redraw_flag = true; // need to update render texture
  bool mipmap_flag = true; // need to recompute mipmap before render

  // this is better than rebinding textures, it is either 0 or 1
  int tex_offset = 0; // the method by which front/back are toggled

  // init helper functions
  void compile_shaders();
  void buffer_geometry();
  void load_textures();
  void cube_geometry(glm::vec3 a, glm::vec3 b, glm::vec3 c, glm::vec3 d,
                     glm::vec3 e, glm::vec3 f, glm::vec3 g, glm::vec3 h,
                     std::vector<glm::vec3> &points,
                     std::vector<glm::vec3> &normals,
                     std::vector<glm::vec3> &colors, glm::vec3 color);

  // display helper functions
  void display_block();
  void display_orientation_widget();

  // OpenGL Data
  // blitting via fullscreen geometry
  GLuint display_vao, display_vbo, display_shader_program;

  // orientation widget with phong shading
  GLuint owidget_vao, owidget_vbo, owidget_shader_program;

  // texture handles
  GLuint textures[13];

  // Compute Shader Handles
  // Shapes
  GLuint aabb_compute;
  GLuint cuboid_compute;
  GLuint cylinder_compute;
  GLuint ellipsoid_compute;
  GLuint grid_compute;
  GLuint heightmap_compute;
  GLuint perlin_compute;
  GLuint sphere_compute;
  GLuint tube_compute;
  GLuint triangle_compute;

  // GPU-side utilities
  GLuint clear_all_compute;
  GLuint unmask_all_compute;
  GLuint invert_mask_compute;
  GLuint mask_by_color_compute;
  GLuint box_blur_compute;
  GLuint gaussian_blur_compute;
  GLuint shift_compute;
  GLuint copy_loadbuff_compute;

  // Lighting
  GLuint lighting_clear_compute;
  GLuint new_directional_lighting_compute;
  GLuint point_lighting_compute;
  GLuint cone_lighting_compute;
  GLuint ambient_occlusion_compute;
  GLuint fakeGI_compute;
  GLuint mash_compute;
};

#endif
