#ifndef DEF_CORE_FBO_H
#define DEF_CORE_FBO_H

#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <GL/glx.h>
#include <GL/glext.h>

//-----------------------------------------------------------------------------
// Class Frame Buffer Object
//-----------------------------------------------------------------------------
class FBO
{
public:
       FBO(size_t width=1280, size_t height=720);
       ~FBO();

       void enable(void);
       void disable(void);


       void setSize(size_t width, size_t height );
       void setFormat(GLint format);

       size_t  getSizeX() const {return m_width;}
       size_t  getSizeY() const {return m_height;}
       GLuint getColor(void) const;
       GLenum getFormat() const {return m_format;}

       void bind();


       inline size_t width() const { return m_width; }
       inline size_t height() const { return m_height; }

private:
       void updateTexture();

       GLuint m_FrameBuffer;
       GLuint m_DepthRenderBuffer;
       GLuint m_ColorTextureID;
       GLuint m_DepthTextureID;
       size_t    m_width,m_height;
       GLint  m_format;
};


#endif
