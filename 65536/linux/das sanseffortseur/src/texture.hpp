#ifndef TEXTURE_H
#define TEXTURE_H
#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <GL/glx.h>
#include <GL/glext.h>


#include <iostream>


class AbstractTexture
{
public:
  AbstractTexture();
  virtual ~AbstractTexture();

  virtual void destroyTexture();

  virtual void update(GLvoid* pixels) = 0;
  virtual void bind() = 0;

  inline GLuint id() const { return m_id; }

protected:
  GLuint m_id;
};



class Texture2D : public AbstractTexture
{
public:
    Texture2D();

    bool create(GLsizei width, GLsizei height, const GLvoid *data = NULL, GLint internalFormat = GL_RGBA, GLenum format = GL_RGBA, GLenum type = GL_UNSIGNED_BYTE);
    virtual void update(GLvoid* pixels);
    virtual void bind();

    inline GLsizei width() const { return m_width; }
    inline GLsizei height() const { return m_height; }

protected:
    GLsizei m_width;
    GLsizei m_height;
    GLenum m_format;
    GLenum m_type;
};

#endif // TEXTURE_H
