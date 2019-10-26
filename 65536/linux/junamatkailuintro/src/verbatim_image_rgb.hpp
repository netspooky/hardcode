#ifndef VERBATIM_IMAGE_RGB_HPP
#define VERBATIM_IMAGE_RGB_HPP

#include "verbatim_realloc.hpp"

// Forward declaration.
class Texture;

/** RGB image class.
 */
class ImageRGB
{
  private:
    /** Image data. */
    float *m_data;

    /** uint8_t data for textures. */
    uint8_t *m_export_data;

    /** Width. */
    unsigned m_width;

    /** Height. */
    unsigned m_height;

  public:
    /** \brief Set Pixel value.
     *
     * \param px X coordinate.
     * \param py Y coordinate.
     * \param pr Red component.
     * \param pg Green component.
     * \param pb Blue component.
     */
    void setPixel(unsigned px, unsigned py, float pr, float pg, float pb)
    {
      unsigned idx = (py * m_width + px) * 3;

      m_data[idx + 0] = pr;
      m_data[idx + 1] = pg;
      m_data[idx + 2] = pb;
    }

  public:
    /** \brief Constructor.
     */
    ImageRGB(unsigned width, unsigned height);

    /** \brief Destructor.
     */
    ~ImageRGB();

  private:
    /** \brief Regenerate export data.
     *
     * Creates the export data when called from current floating point data.
     *
     * \return Export data.
     */
    uint8_t* getExportData();

  public:
    /** \brief Create texture from this image.
     *
     * \return Newly created texture.
     */
    Texture* createTexture();

    /** \brief Apply a low-pass filter over the texture.
     *
     * This low-pass filter will wrap around the texture edges.
     *
     * \param op Kernel size.
     */
    void filterLowpass(int op);
};

#endif
