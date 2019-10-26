#include "verbatim_image_rgb.hpp"

#include "verbatim_texture.hpp"

ImageRGB::ImageRGB(unsigned width, unsigned height) :
  m_data(array_new(static_cast<float*>(NULL), width * height * 3)),
  m_export_data(NULL),
  m_width(width),
  m_height(height) { }

ImageRGB::~ImageRGB()
{
  array_delete(m_data);
  array_delete(m_export_data);
}

uint8_t* ImageRGB::getExportData()
{
  unsigned count = m_width * m_height * 3;

  m_export_data = array_new(m_export_data, count);

  for(unsigned ii = 0; (ii < count); ++ii)
  {
    m_export_data[ii] = static_cast<uint8_t>(0.5f + 
        dnload_fminf(dnload_fmaxf(m_data[ii], 0.0f), 1.0f) * 255.0f);
  }

  return m_export_data;
}

Texture* ImageRGB::createTexture()
{
  return new Texture(m_width, m_height, 3, this->getExportData());
}

void ImageRGB::filterLowpass(int op)
{
  float *replacement_data = array_new(static_cast<float*>(NULL), m_width * m_height * 3);
  int iwidth = static_cast<int>(m_width);
  int iheight = static_cast<int>(m_height);

  for(int ii = 0; (ii < iwidth); ++ii)
  {
    for(int jj = 0; (jj < iwidth); ++jj)
    {
      int idx = (jj * iwidth + ii) * 3;
      int divisor = 0;
      float val1 = 0.0f;
      float val2 = 0.0f;
      float val3 = 0.0f;

      for(int kk = -op; (kk <= op); ++kk)
      {
        int rx = ii + kk;

        if(rx < 0)
        {
          rx = iwidth + rx;
        }
        else if(rx >= iwidth)
        {
          rx -= iwidth;
        }

        for(int ll = -op; (ll <= op); ++ll)
        {
          int ry = jj + ll;

          if(ry < 0)
          {
            ry = iheight + ry;
          }
          else if(ry >= iheight)
          {
            ry -= iheight;
          }

          int cidx = (ry * iwidth + rx) * 3;

          val1 += m_data[cidx + 0];
          val2 += m_data[cidx + 1];
          val3 += m_data[cidx + 2];

          ++divisor;
        }
      }

      replacement_data[idx + 0] = val1 / static_cast<float>(divisor);
      replacement_data[idx + 1] = val2 / static_cast<float>(divisor);
      replacement_data[idx + 2] = val3 / static_cast<float>(divisor);
    }
  }

  array_delete(m_data);
  m_data = replacement_data;
}

