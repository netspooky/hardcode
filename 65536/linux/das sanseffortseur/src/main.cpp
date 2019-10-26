#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <GL/glx.h>
#include <GL/glext.h>

#include "system.hpp"
#include "scenes.hpp"
#include "sequences.hpp"
#include "music.hpp"
#include "tf4.hpp"
#include "fbo.hpp"
#include "texture.hpp"

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>

#ifdef eGTK
#include <gtk-2.0/gtk/gtk.h>
#endif


//#include <SFML/Audio.hpp>
//#include <SFML/Graphics.hpp>


#include "window.hpp"
#include "vec3.hpp"
#include "RtAudio.h"

#ifdef eDEBUG

// In debug mode, perform a test on every OpenGL call
// The do-while loop is needed so that glCheck can be used as a single statement in if/else branches
#define glCheck(expr) do { expr; glCheckError(__FILE__, __LINE__, #expr); } while (false)

void glCheckError(const char* file, unsigned int line, const char* expression)
{
  // Get the last error
  GLenum errorCode = glGetError();

  if (errorCode != GL_NO_ERROR)
  {
    std::string fileString = file;
    std::string error = "Unknown error";
    std::string description  = "No description";

    // Decode the error code
    switch (errorCode)
    {
      case GL_INVALID_ENUM:
        {
          error = "GL_INVALID_ENUM";
          description = "An unacceptable value has been specified for an enumerated argument.";
          break;
        }

      case GL_INVALID_VALUE:
        {
          error = "GL_INVALID_VALUE";
          description = "A numeric argument is out of range.";
          break;
        }

      case GL_INVALID_OPERATION:
        {
          error = "GL_INVALID_OPERATION";
          description = "The specified operation is not allowed in the current state.";
          break;
        }

      case GL_STACK_OVERFLOW:
        {
          error = "GL_STACK_OVERFLOW";
          description = "This command would cause a stack overflow.";
          break;
        }

      case GL_STACK_UNDERFLOW:
        {
          error = "GL_STACK_UNDERFLOW";
          description = "This command would cause a stack underflow.";
          break;
        }

      case GL_OUT_OF_MEMORY:
        {
          error = "GL_OUT_OF_MEMORY";
          description = "There is not enough memory left to execute the command.";
          break;
        }

      case GLEXT_GL_INVALID_FRAMEBUFFER_OPERATION:
        {
          error = "GL_INVALID_FRAMEBUFFER_OPERATION";
          description = "The object bound to FRAMEBUFFER_BINDING is not \"framebuffer complete\".";
          break;
        }
    }

    // Log the error
    std::cerr << "An internal OpenGL call failed in "
              << fileString.substr(fileString.find_last_of("\\/") + 1) << "(" << line << ")."
              << "\nExpression:\n   " << expression
              << "\nError description:\n   " << error << "\n   " << description << "\n"
              << std::endl;
  }
}

#else

#define glCheck(expr) (expr)

#endif




unsigned int width = 854;
unsigned int height = 480;
bool start=true;
bool fullscreen = false;
bool fxaa = false;

#define BUFFER_OFFSET(a) ((char*)NULL + (a))
struct vec2
{
  float x,y;
};

static GLuint vbo;

void Fast2DQuadInit(void)
{
  vec2 point[4];
  point[0].x =-1.0f; point[1].x = 1.0f; point[2].x =-1.0f; point[3].x = 1.0f;
  point[0].y =-1.0f; point[1].y =-1.0f; point[2].y = 1.0f; point[3].y = 1.0f;
  vec2 uv[4];
  uv[0].x = 0.0f; uv[1].x = 1.0f; uv[2].x = 0.0f; uv[3].x = 1.0f;
  uv[0].y = 0.0f; uv[1].y = 0.0f; uv[2].y = 1.0f; uv[3].y = 1.0f;


  //make the vertex buffer object
  glGenBuffers(1, &vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, 4*2*sizeof(float)*2, NULL, GL_STATIC_DRAW);
  glBufferSubData(GL_ARRAY_BUFFER, 0, 4*2*sizeof(float), point);
  glBufferSubData(GL_ARRAY_BUFFER, 4*2*sizeof(float), 4*2*sizeof(float), uv);
  glBindBuffer(GL_ARRAY_BUFFER, 0);

}


void Fast2DQuadDraw(void)
{
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glVertexPointer(2, GL_FLOAT, 0, BUFFER_OFFSET(0));
  glTexCoordPointer(2, GL_FLOAT, 0, BUFFER_OFFSET(4*2*sizeof(float)));
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}



//std::vector<sf::Shader*> scenes_shaders;
static const char* vertexShader =
    "#version 120\n"
    "varying vec2 coords;"
    "void main()"
    "{"
    "coords         = (gl_ModelViewProjectionMatrix * gl_Vertex).xy;"
    "gl_Position    = gl_ModelViewProjectionMatrix * gl_Vertex;"
    "gl_TexCoord[0] = gl_MultiTexCoord0;"
    "}";


static const char* postProcessVertexShader =
    "varying vec2 v_rgbNW;"
    "varying vec2 v_rgbNE;"
    "varying vec2 v_rgbSW;"
    "varying vec2 v_rgbSE;"
    "varying vec2 v_rgbM;"
    "uniform vec2 resolution;"
    "void texcoords(vec2 fragCoord, vec2 resolution,"
    "out vec2 v_rgbNW, out vec2 v_rgbNE,"
    "out vec2 v_rgbSW, out vec2 v_rgbSE,"
    "out vec2 v_rgbM) {"
    "vec2 inverseVP = 1.0 / resolution.xy;"
    "v_rgbNW = (fragCoord + vec2(-1.0, -1.0)) * inverseVP;"
    "v_rgbNE = (fragCoord + vec2(1.0, -1.0)) * inverseVP;"
    "v_rgbSW = (fragCoord + vec2(-1.0, 1.0)) * inverseVP;"
    "v_rgbSE = (fragCoord + vec2(1.0, 1.0)) * inverseVP;"
    "v_rgbM = vec2(fragCoord * inverseVP);"
    "}"
    "void main() {"
    "gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;"
    "vec2 fragCoord = gl_TexCoord[0] * resolution;"
    "texcoords(fragCoord, resolution, v_rgbNW, v_rgbNE, v_rgbSW, v_rgbSE, v_rgbM);"
    "gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;"
    "gl_FrontColor = gl_Color;"

    "}";

static const char* postProcessFragmentShader =
    "#version 120\n"
    "#ifndef FXAA_REDUCE_MIN\n"
    "#define FXAA_REDUCE_MIN   (1.0/ 128.0)\n"
    "#endif\n"
    "#ifndef FXAA_REDUCE_MUL\n"
    "#define FXAA_REDUCE_MUL   (1.0 / 8.0)\n"
    "#endif\n"
    "#ifndef FXAA_SPAN_MAX\n"
    "#define FXAA_SPAN_MAX     8.0\n"
    "#endif\n"
    "varying vec2 v_rgbNW;"
    "varying vec2 v_rgbNE;"
    "varying vec2 v_rgbSW;"
    "varying vec2 v_rgbSE;"
    "varying vec2 v_rgbM;"
    "uniform vec2 resolution;"
    "vec4 fxaa(sampler2D tex, vec2 fragCoord, vec2 resolution,"
    "vec2 v_rgbNW, vec2 v_rgbNE,"
    "vec2 v_rgbSW, vec2 v_rgbSE,"
    "vec2 v_rgbM) {"
    "vec4 color;"
    "mediump vec2 inverseVP = vec2(1.0 / resolution.x, 1.0 / resolution.y);"
    "vec3 rgbNW = texture2D(tex, v_rgbNW).xyz;"
    "vec3 rgbNE = texture2D(tex, v_rgbNE).xyz;"
    "vec3 rgbSW = texture2D(tex, v_rgbSW).xyz;"
    "vec3 rgbSE = texture2D(tex, v_rgbSE).xyz;"
    "vec4 texColor = texture2D(tex, v_rgbM);"
    "vec3 rgbM  = texColor.xyz;"
    "vec3 luma = vec3(0.299, 0.587, 0.114);"
    "float lumaNW = dot(rgbNW, luma);"
    "float lumaNE = dot(rgbNE, luma);"
    "float lumaSW = dot(rgbSW, luma);"
    "float lumaSE = dot(rgbSE, luma);"
    "float lumaM  = dot(rgbM,  luma);"
    "float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));"
    "float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));"

    "mediump vec2 dir;"
    "dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));"
    "dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));"

    "float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) *"
    "(0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);"

    "float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);"
    "dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),"
    "max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),"
    "dir * rcpDirMin)) * inverseVP;"

    "vec3 rgbA = 0.5 * ("
    "texture2D(tex, fragCoord * inverseVP + dir * (1.0 / 3.0 - 0.5)).xyz +"
    "texture2D(tex, fragCoord * inverseVP + dir * (2.0 / 3.0 - 0.5)).xyz);"
    "vec3 rgbB = rgbA * 0.5 + 0.25 * ("
    "texture2D(tex, fragCoord * inverseVP + dir * -0.5).xyz +"
    "texture2D(tex, fragCoord * inverseVP + dir * 0.5).xyz);"

    "float lumaB = dot(rgbB, luma);"
    "if ((lumaB < lumaMin) || (lumaB > lumaMax))"
    "color = vec4(rgbA, texColor.a);"
    "else "
    "color = vec4(rgbB, texColor.a);"
    "return color;"
    "}"


    "uniform sampler2D texture;"
    "void main()"
    "{"
    "vec2 fragCoord = gl_TexCoord[0].xy * resolution;"
    "gl_FragColor = fxaa(texture, fragCoord, resolution, v_rgbNW, v_rgbNE, v_rgbSW, v_rgbSE, v_rgbM);"
    "}"
    ;

/*
static const char* testShader =
  "#version 120\n"
  "varying vec2 coords;"
  "uniform float track_time;"
  "void main()"
  "{"
     //"if (coords.x > 0. && coords.y  > 0.) gl_FragColor = vec4(1.,1.,1.,1.);"
     //"else if (coords.x > 0.) gl_FragColor = vec4(1.,0.,1.,1.);"
     //"else if (coords.y > 0.) gl_FragColor = vec4(0.,1.,1.,1.);"
     //"else gl_FragColor = vec4(0.,0.,1.,1.);"
    "gl_FragColor = vec4(abs(cos(track_time + coords.x)),abs(cos(3.*track_time + coords.y)),0.5*abs(coords.x + coords.y),1.);"
  "}";
*/

GLint postProcessShaderID;
void compileShaders()
{
  if (fxaa)
  {

    glCheck(postProcessShaderID = glCreateProgram());
    GLint vs;
    glCheck(vs = glCreateShader(GL_VERTEX_SHADER));
    glCheck(glShaderSource(vs,1,&postProcessVertexShader,0));
    glCheck(glCompileShader(vs));
    glCheck(glAttachShader(postProcessShaderID,vs));
#ifdef eDEBUG
    glCheck(glDeleteShader(vs));
#endif

    GLint fs;
    glCheck(fs = glCreateShader(GL_FRAGMENT_SHADER));
    glCheck(glShaderSource(fs,1,&postProcessFragmentShader,0));
    glCheck(glCompileShader(fs));
    glCheck(glAttachShader(postProcessShaderID,fs));
#ifdef eDEBUG
    glCheck(glDeleteShader(fs));
#endif

    glCheck(glLinkProgram(postProcessShaderID));



  }
  for (int i=0 ;i < SCENES_COUNT; i++)
  {
    std::string code = scenes_src[i];


    if (scenes_framework_src[i])
    {
      code = std::string(scenes_framework_src[i]) + code;
    }

    glCheck(*(scenes_programs[i]) = glCreateProgram());

    GLint vs;
    glCheck(vs = glCreateShader(GL_VERTEX_SHADER));
    glCheck(glShaderSource(vs,1,&(vertexShader),0));
    glCheck(glCompileShader(vs));
    glCheck(glAttachShader(*(scenes_programs[i]),vs));
#ifdef eDEBUG
    glCheck(glDeleteShader(vs));
#endif


    const char* fcode = code.c_str();
    GLint fs;
    glCheck(fs = glCreateShader(GL_FRAGMENT_SHADER));
    glCheck(glShaderSource(fs,1,&(fcode),0));
    glCheck(glCompileShader(fs));
    glCheck(glAttachShader(*(scenes_programs[i]),fs));
#ifdef eDEBUG
    glCheck(glDeleteShader(fs));
#endif

    glCheck(glLinkProgram(*(scenes_programs[i])));


    /*
      sf::Shader* scene = new sf::Shader;
      if (!scene->loadFromMemory(vertexShader,code))
      {
        std::cerr << "Unable to load the shader : " << code << std::endl;
        exit(-1);
      }

      (*scenes_programs[i]) = i;

      scenes_shaders.push_back(scene);
      */
  }
}



int audioCallback( void *outputBuffer, void *, unsigned int ,
                   double , RtAudioStreamStatus , void *userData )
{
  const eU64 size = TF_FRAMESIZE*2*sizeof(eS16);

  eTfPlayer* player = (eTfPlayer*) userData;
  eASSERT(nBufferFrames == TF_FRAMESIZE);
  const eU8* data;
  eTfPlayerProcess(*player,&data);
  eMemCopy(outputBuffer,data, size);
  return 0;
}

/*
class Stream : public sf::SoundStream
{
public:
  Stream(eTfPlayer& p):
    sf::SoundStream(),
    player(p)
  {
    initialize(2,44100);
    eTfPlayerStart(player, 0);
  }

  eTfPlayer& player;

private:
  virtual bool onGetData(Chunk &data)
  {
    sf::Int16* samples;
    eTfPlayerProcess(player,(const eU8**)(&samples));
    data.samples = samples;
    data.sampleCount = TF_FRAMESIZE * 2;
    return true;
  }

  virtual void onSeek(sf::Time)
  {

  }

};

*/

float q_Dot(float q0_x, float q0_y ,float q0_z, float q0_w,
            float q1_x, float q1_y ,float q1_z, float q1_w)
{
  return q0_x*q1_x + q0_y*q1_y + q0_z*q1_z + q0_w*q1_w;
}

float q_Norm(float q0_x, float q0_y ,float q0_z, float q0_w)
{
  return q0_w*q0_w + q0_x*q0_x + q0_y*q0_y + q0_z*q0_z;
}

void q_normalise(float& q_x, float& q_y ,float& q_z, float& q_w)
{
  float len = q_Norm(q_x,q_y,q_z,q_w);
  float factor = 1.0f/sqrt(len);

  q_x *= factor;
  q_y *= factor;
  q_z *= factor;
  q_w *= factor;
}


void q_nlerp(float q0_x, float q0_y ,float q0_z, float q0_w,
             float q1_x, float q1_y ,float q1_z, float q1_w,
             float& q_x, float& q_y ,float& q_z, float& q_w, float delta)
{
  float fCos = q_Dot(q0_x, q0_y ,q0_z, q0_w,
                     q1_x, q1_y ,q1_z, q1_w);

  if (fCos < 0)
  {
    q_x = q0_x + delta * ((-q1_x) - q0_x);
    q_y = q0_y + delta * ((-q1_y) - q0_y);
    q_z = q0_z + delta * ((-q1_z) - q0_z);
    q_w = q0_w + delta * ((-q1_w) - q0_w);
  }
  else
  {
    q_x = q0_x + delta * (q1_x - q0_x);
    q_y = q0_y + delta * (q1_y - q0_y);
    q_z = q0_z + delta * (q1_z - q0_z);
    q_w = q0_w + delta * (q1_w - q0_w);
  }
  q_normalise(q_x,q_y,q_z,q_w);
}


#ifdef eGTK

GtkWidget* resolutionComboBox;
GtkWidget* fullscreenCheckButton;
GtkWidget* fxaaCheckButton;


static void demo_event( GtkWidget *widget,
                        gpointer   data )
{
  start = true;
  if (std::string("426x240 (16:9)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 426;
    height = 240;
  }
  else if (std::string("640x360 (16:9)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 640;
    height = 360;
  }
  else if (std::string("854x480 (16:9)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 854;
    height = 480;
  }
  else if (std::string("1280x720 (16:9)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1280;
    height = 720;
  }
  else if (std::string("1600x900 (16:9)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1600;
    height = 900;
  }
  else if (std::string("1920x1080 (16:9)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1920;
    height = 1080;
  }

  else if (std::string("640x480 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 640;
    height = 480;
  }
  else if (std::string("800x600 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 800;
    height = 600;
  }
  else if (std::string("1024x768 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1024;
    height = 768;
  }
  else if (std::string("1152x864 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1152;
    height = 864;
  }
  else if (std::string("1280x960 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1280;
    height = 960;
  }
  else if (std::string("1400x1050 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1400;
    height = 1050;
  }
  else if (std::string("1600x1200 (4:3)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1600;
    height = 1200;
  }


  else if (std::string("1440x900 (16:10)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1440;
    height = 900;
  }
  else if (std::string("1680x1050 (16:10)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1680;
    height = 1050;
  }
  else if (std::string("1920x1200 (16:10)") == gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(resolutionComboBox)))
  {
    width = 1920;
    height = 1200;
  }

  fullscreen = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(fullscreenCheckButton));
  fxaa = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(fxaaCheckButton));

}

static void die_event( GtkWidget *widget,
                       gpointer   data )
{
  start = false;
}

static void destroy_event( GtkWidget *widget,
                           gpointer   data )
{
  gtk_main_quit ();
}

static gboolean delete_event( GtkWidget *widget,
                              GdkEvent  *event,
                              gpointer   data )
{
  start = false;
  return FALSE;
}


#endif


int main(int   argc, char *argv[])
{



#ifdef eGTK
  GtkWidget *win;
  GtkWidget *demoButton;
  GtkWidget *dieButton;
  GtkWidget *buttonsBox;
  GtkWidget *resolutionBox;
  GtkWidget *paramBox;
  GtkWidget *labelBox;
  GtkWidget *thxBox;
  GtkWidget *winBox;
  GtkWidget *resolutionLabel;
  GtkWidget *codeCreditLabel;
  GtkWidget *musicCreditLabel;
  GtkWidget *synthCreditLabel;
  GtkWidget *xtCreditLabel;
  GtkWidget *andreCreditLabel;

  GtkWidget *vsep0;
  GtkWidget *vsep1;
  GtkWidget *vsep2;
  GtkWidget *vsep3;


  gtk_init (&argc, &argv);

  win = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_container_set_border_width (GTK_CONTAINER (win), 10);
  gtk_window_set_title (GTK_WINDOW (win), "Das Sanseffortseur Launcher");
  gtk_window_set_resizable(GTK_WINDOW (win),FALSE);
  gtk_window_set_position(GTK_WINDOW (win),GTK_WIN_POS_CENTER_ALWAYS);

  g_signal_connect (win, "destroy",
                    G_CALLBACK (destroy_event), NULL);

  g_signal_connect (win, "delete-event",
                    G_CALLBACK (delete_event), NULL);

  demoButton = gtk_button_new_with_label ("Demo !");
  dieButton = gtk_button_new_with_label ("Die !");


  vsep0 = gtk_hseparator_new();
  vsep1 = gtk_hseparator_new();
  vsep2 = gtk_hseparator_new();
  vsep3 = gtk_hseparator_new();

  resolutionComboBox = gtk_combo_box_text_new ();

  resolutionLabel = gtk_label_new("Resolution: ");
  codeCreditLabel = gtk_label_new(0);
  gtk_label_set_markup(GTK_LABEL(codeCreditLabel),"Code &#38; Tool: <a href=\"https://twitter.com/lamogui42\">Julien De Loor</a>");
  musicCreditLabel = gtk_label_new(0);
  gtk_label_set_markup(GTK_LABEL(musicCreditLabel),"Music: <a href=\"https://soundcloud.com/314air\">Pierre De Loor</a>");
  synthCreditLabel = gtk_label_new(0);
  gtk_label_set_markup(GTK_LABEL(synthCreditLabel),"Synth: <a href=\"https://www.tunefish-synth.com/\">Tunefish4</a> by Braincontrol");
  xtCreditLabel = gtk_label_new("Special thx to xt95 for help and codebase");
  andreCreditLabel = gtk_label_new(0);
  gtk_label_set_markup(GTK_LABEL(andreCreditLabel),"This demo use a <a href=\"https://www.shadertoy.com/view/4s3XDn\">font</a> by Andre");

  fullscreenCheckButton = gtk_check_button_new_with_label("fullscreen");
  fxaaCheckButton = gtk_check_button_new_with_label("fxaa");

  //gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(fxaaCheckButton), TRUE);

  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "426x240 (16:9)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "640x360 (16:9)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "854x480 (16:9)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1280x720 (16:9)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1600x900 (16:9)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1920x1080 (16:9)");


  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "640x480 (4:3)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "800x600 (4:3)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1024x768 (4:3)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1152x864 (4:3)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1280x960 (4:3)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1400x1050 (4:3)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1600x1200 (4:3)");

  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1440x900 (16:10)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1680x1050 (16:10)");
  gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT (resolutionComboBox), "1920x1200 (16:10)");

  gtk_combo_box_set_active(GTK_COMBO_BOX(resolutionComboBox),0);

  g_signal_connect_swapped (demoButton, "clicked",
                            G_CALLBACK (demo_event),
                            win);
  g_signal_connect_swapped (dieButton, "clicked",
                            G_CALLBACK (die_event),
                            win);
  g_signal_connect_swapped (demoButton, "clicked",
                            G_CALLBACK (gtk_widget_destroy),
                            win);
  g_signal_connect_swapped (dieButton, "clicked",
                            G_CALLBACK (gtk_widget_destroy),
                            win);

  buttonsBox = gtk_hbox_new (FALSE, 0);
  resolutionBox = gtk_hbox_new (FALSE, 0);
  winBox= gtk_vbox_new (FALSE, 0);
  labelBox = gtk_vbox_new (FALSE, 0);
  paramBox = gtk_vbox_new (FALSE, 0);
  thxBox = gtk_vbox_new (FALSE, 0);


  gtk_box_pack_start (GTK_BOX(labelBox), codeCreditLabel, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(labelBox), musicCreditLabel, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(labelBox), synthCreditLabel, TRUE, TRUE, 0);

  gtk_container_set_border_width (GTK_CONTAINER (buttonsBox), 10);
  gtk_container_set_border_width (GTK_CONTAINER (paramBox), 10);
  gtk_container_set_border_width (GTK_CONTAINER (labelBox), 10);
  gtk_container_set_border_width (GTK_CONTAINER (thxBox), 10);

  gtk_box_pack_start (GTK_BOX(resolutionBox), resolutionLabel, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(resolutionBox), resolutionComboBox, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(paramBox), resolutionBox, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(paramBox), fullscreenCheckButton, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(paramBox), fxaaCheckButton, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(buttonsBox), demoButton, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(buttonsBox), dieButton, TRUE, TRUE, 0);


  gtk_box_pack_start (GTK_BOX(thxBox), andreCreditLabel, TRUE, TRUE, 0);
  gtk_box_pack_start (GTK_BOX(thxBox), xtCreditLabel, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), vsep0, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), labelBox, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), vsep1, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), paramBox, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), vsep2, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), thxBox, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), vsep3, TRUE, TRUE, 0);

  gtk_box_pack_start (GTK_BOX(winBox), buttonsBox, TRUE, TRUE, 0);



  gtk_box_set_child_packing(GTK_BOX(buttonsBox), demoButton, FALSE, FALSE, 0,GTK_PACK_END);
  gtk_box_set_child_packing(GTK_BOX(buttonsBox), dieButton, FALSE, FALSE, 0,GTK_PACK_END);


  gtk_container_add (GTK_CONTAINER (win), winBox);

  gtk_widget_show (demoButton);
  gtk_widget_show (dieButton);
  gtk_widget_show (buttonsBox);
  gtk_widget_show (resolutionBox);
  gtk_widget_show (winBox);
  gtk_widget_show (resolutionLabel);
  gtk_widget_show (codeCreditLabel);
  gtk_widget_show (musicCreditLabel);
  gtk_widget_show (synthCreditLabel);
  gtk_widget_show (resolutionComboBox);
  gtk_widget_show(fullscreenCheckButton);
  gtk_widget_show(fxaaCheckButton);
  gtk_widget_show(vsep0);
  gtk_widget_show(vsep1);
  gtk_widget_show(vsep2);
  gtk_widget_show(vsep3);
  gtk_widget_show(labelBox);
  gtk_widget_show(paramBox);
  gtk_widget_show(thxBox);

  gtk_widget_show(xtCreditLabel);
  gtk_widget_show(andreCreditLabel);

  gtk_widget_show  (win);

  gtk_main ();

#endif

  if (!start)
  {
    return 0xdead;
  }

  /*
  sf::View view(sf::FloatRect(-1,-1,2,2));

  sf::RenderTexture render;
  render.create(width,height);
  render.setSmooth(true);
  render.setView(view);


  sf::RectangleShape fast2dquad;
  fast2dquad.setSize(sf::Vector2f(2,2));
  fast2dquad.setPosition(sf::Vector2f(-1,-1));

  sf::VideoMode video_mode = sf::VideoMode(render.getSize().x, render.getSize().y);

  if (fullscreen)
  {
    video_mode = sf::VideoMode::getDesktopMode();
  }
  sf::RenderWindow window(video_mode, "Das Sanseffortseur");
  window.setVerticalSyncEnabled(true);
*/

  Win window("Das Sanseffortseur", width,height, fullscreen);
  Fast2DQuadInit();
  compileShaders();

  FBO fbo(width,height);


  /*
  render.setActive(true);
  //Fast2DQuadInit();

  sf::Sprite sprite(render.getTexture());
  sf::Texture noteVelocityTex;
*/


  eTfPlayer player;
  eTfPlayerInit(player,44100);
  eTfPlayerLoadSong(player,music,music_length,0);
  eTfPlayerStart(player, 0);

  //noteVelocityTex.create(TF_NUMFREQS,player.song.instrCount);
  Texture2D noteVelocityTex;
  eF32* noteVelocityBuffer = new eF32[player.song.instrCount*TF_NUMFREQS*sizeof(eF32)];
  noteVelocityTex.create(TF_NUMFREQS,player.song.instrCount,(GLvoid*)noteVelocityBuffer,GL_R32F,GL_RED, GL_FLOAT);


  //Stream stream(player);
  /*  window.clear();
  window.display();

  sprite.setScale((float)window.getSize().x/(float)render.getSize().x, (float)window.getSize().y/(float)render.getSize().y);
*/




  //sf::sleep(sf::milliseconds(500));



  RtAudio dac;
  if ( dac.getDeviceCount() < 1 ) {
    std::cout << "\nNo audio devices found!\n";
    exit( 0 );
  }
  RtAudio::StreamParameters parameters;
  parameters.deviceId = dac.getDefaultOutputDevice();
  parameters.nChannels = 2;
  parameters.firstChannel = 0;
  unsigned int sampleRate = 44100;
  unsigned int bufferFrames = TF_FRAMESIZE;
  try {
    dac.openStream( &parameters, NULL, RTAUDIO_SINT16,
                    sampleRate, &bufferFrames, &audioCallback, (void *)&player);
    dac.startStream();
  }
  catch ( RtAudioError& e ) {
    e.printMessage();
    exit( 0 );
  }

  unsigned int current_seq = 0;

  /* sf::Text fps;
  sf::Font font;
  font.loadFromFile("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf");
  fps.setColor(sf::Color(255,255,255,255));
  fps.setFont(font);
*/

  /*
  sf::Shader test_shader;
  if (!test_shader.loadFromMemory(vertexShader,testShader))
  {
    std::cerr << "Errror loadinf test shader" << std::endl;
    return -1;
  }
*/

  //stream.play();
  // Start the game loop

  /* sf::Clock clock;
  clock.restart();
  float lastTime = clock.getElapsedTime().asSeconds();
  sf::Shader postProcessShader;
  if (fxaa && !postProcessShader.loadFromMemory(postProcessVertexShader,postProcessFragmentShader))
  {
    std::cerr << "Unable to load post process shader" << std::endl;
  }*/

  //while (window.isOpen())

  while (window.Event())
  {
    /* // Process events
    sf::Event event;
    while (window.pollEvent(event))
    {
      // Close window: exit
      if (event.type == sf::Event::Closed ||
          (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Escape))
      {
        window.close();
      }
    }

*/

    float track_time = player.time;
    unsigned short current_frame = (unsigned short)(track_time*FRAMERATE);
    float sequence_time = (float)(current_frame - seq_start_frame[current_seq])/(float)FRAMERATE;
    //float xy_scale_factor = (float)render.getSize().x/(float)render.getSize().y;
    float xy_scale_factor = (float) window.width/(float)window.height;

    //std::cout << window.width << "x" << window.height << std::endl;

    //std::cout << "current_seq " << current_seq << " seq_start_frame[current_seq + 1] " << seq_start_frame[current_seq + 1]  << " current_frame " << current_frame << std::endl;

    if ((current_seq + 1 < SEQUENCES_COUNT) &&
        (seq_start_frame[current_seq + 1] <= current_frame))
    {
      current_seq += 1;
    }
    /*
    sf::Vector3f cam_pos;
    sf::Vector3f cam_rot;*/
    vec3 cam_pos;
    vec3 cam_rot;
    float cam_w = 1;
    unsigned short relative_frame = current_frame - seq_start_frame[current_seq];

    int begin_cam = -1;
    int end_cam = -1;

    if (seq_cam_keyframe_count[current_seq] >1)
    {

      for (int i = seq_start_cam_keyframe[current_seq] ; i < seq_start_cam_keyframe[current_seq] + seq_cam_keyframe_count[current_seq]; i++)
      {

        if (cam_frame[i] <= relative_frame)
        {
          begin_cam = i;
        }
        else if (cam_frame[i] > relative_frame)
        {
          end_cam = i;
          break;
        }
      }

      if (begin_cam != -1 && end_cam != -1)
      {
        float delta = (float) (relative_frame - cam_frame[begin_cam])/
            (float) (cam_frame[end_cam] - cam_frame[begin_cam]);

        float delta_inv = 1.f-delta;
        // cam_pos = (sf::Vector3f(cam_pos_x[end_cam], cam_pos_y[end_cam], cam_pos_z[end_cam]) * delta) +
        //          (sf::Vector3f(cam_pos_x[begin_cam], cam_pos_y[begin_cam], cam_pos_z[begin_cam]) * delta_inv);

        cam_pos = (vec3(cam_pos_x[end_cam], cam_pos_y[end_cam], cam_pos_z[end_cam]) * delta) +
            (vec3(cam_pos_x[begin_cam], cam_pos_y[begin_cam], cam_pos_z[begin_cam]) * delta_inv);

        q_nlerp(cam_rot_x[begin_cam], cam_rot_y[begin_cam], cam_rot_z[begin_cam], cam_rot_w[begin_cam],
                cam_rot_x[end_cam], cam_rot_y[end_cam], cam_rot_z[end_cam], cam_rot_w[end_cam],
                cam_rot.x,cam_rot.y,cam_rot.z,cam_w,delta);
      }
      else if (begin_cam != -1)
      {
        cam_rot.x = cam_rot_x[begin_cam];
        cam_rot.y = cam_rot_y[begin_cam];
        cam_rot.z = cam_rot_z[begin_cam];
        cam_w = cam_rot_w[begin_cam];
      }
      else if (end_cam != -1)
      {
        cam_rot.x = cam_rot_x[end_cam];
        cam_rot.y = cam_rot_y[end_cam];
        cam_rot.z = cam_rot_z[end_cam];
        cam_w = cam_rot_w[end_cam];
      }
    }
    else if (seq_cam_keyframe_count[current_seq] == 1)
    {
      unsigned int i = seq_start_cam_keyframe[current_seq];
      cam_pos.x = cam_pos_x[i];
      cam_pos.y = cam_pos_y[i];
      cam_pos.z = cam_pos_z[i];
      cam_rot.x = cam_rot_x[i];
      cam_rot.y = cam_rot_y[i];
      cam_rot.z = cam_rot_z[i];
      cam_w = cam_rot_w[i];
    }


    GLint current_scene = *(seq_shader[current_seq]);

    glUseProgram(current_scene);
    glUniform1f(glGetUniformLocation(current_scene,"track_time"),track_time);
    glUniform1f(glGetUniformLocation(current_scene,"sequence_time"),sequence_time);
    glUniform1f(glGetUniformLocation(current_scene,"xy_scale_factor"),xy_scale_factor);
    glUniform3f(glGetUniformLocation(current_scene,"cam_position"),cam_pos.x, cam_pos.y, cam_pos.z);
    glUniform4f(glGetUniformLocation(current_scene,"cam_rotation"),cam_rot.x, cam_rot.y, cam_rot.z,cam_w);
    glUniform1i(glGetUniformLocation(current_scene,"notes_velocity"),0);
    glUseProgram(0);


    /*
    sf::Shader* current_scene = scenes_shaders[*(seq_shader[current_seq])];



    current_scene->setParameter("track_time", track_time);
    current_scene->setParameter("sequence_time", sequence_time);
    current_scene->setParameter("xy_scale_factor", xy_scale_factor);
    current_scene->setParameter("cam_position", cam_pos);
    current_scene->setParameter("cam_rotation",cam_rot.x,cam_rot.y,cam_rot.z,cam_w);
    current_scene->setParameter("notes_velocity",noteVelocityTex);

   std::cout << "track_time " << track_time
              << " sequence_time " << sequence_time
              << " xy_scale_factor " << xy_scale_factor << std::endl;
*/

    memset((void*)noteVelocityBuffer,0,player.song.instrCount*TF_NUMFREQS*4);
    for (size_t i =0 ; i < player.song.instrCount; i++)
    {
      for (size_t k = 0; k < TF_MAXVOICES; k++)
      {
        if (player.synth.instr[i]->voice[k].noteIsOn)
        {
          eU32 note = player.synth.instr[i]->voice[k].currentNote%TF_NUMFREQS;
          eF32 velocity = 2*player.synth.instr[i]->voice[k].currentVelocity/128.0;
          noteVelocityBuffer[note + TF_NUMFREQS * i] = std::max(velocity,noteVelocityBuffer[note + TF_NUMFREQS * i]);
        }
      }
    }


    noteVelocityTex.update(noteVelocityBuffer);

    fbo.enable();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    glUseProgram(current_scene);
    glActiveTexture(GL_TEXTURE0);
    noteVelocityTex.bind();

    Fast2DQuadDraw();
    glUseProgram(0);
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    fbo.disable();


    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (fxaa)
    {
      glUseProgram(postProcessShaderID);
      glUniform2f(glGetUniformLocation(postProcessShaderID,"resolution"),fbo.width(),fbo.height());
      glUniform1i(glGetUniformLocation(postProcessShaderID,"texture"),0);
    }
    glActiveTexture(GL_TEXTURE0);
    fbo.bind();
    Fast2DQuadDraw();
    if (fxaa)
    {
      glUseProgram(0);
    }

    glFlush();
    window.Flush();

    /*    noteVelocityTex.update(noteVelocityBuffer);

    render.setActive(true);
    render.clear();
    sf::Shader::bind(current_scene);
    render.draw(fast2dquad);
    sf::Shader::bind(0);
    render.display();


    sprite.setTexture(render.getTexture(),true);

    std::stringstream s;


    if (show_fps)
    {
    float currentTime = clock.getElapsedTime().asSeconds();
    s << (int)(1.f / (currentTime - lastTime));
    lastTime = currentTime;

    s.flush();
    fps.setString(s.str());




    }

    window.clear();
    if (fxaa)
    {
      postProcessShader.setParameter("resolution",sf::Vector2f(render.getSize().x,render.getSize().y));
      sf::Shader::bind(&postProcessShader);
    }
    window.draw(sprite);
    sf::Shader::bind(0);

    if (show_fps)
    {
      window.draw(fps);
    }
    window.display();*/
  }
  return 0xdead;
}



