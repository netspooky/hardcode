#ifndef VERBATIM_VERTEX_HPP
#define VERBATIM_VERTEX_HPP

#include "verbatim_color.hpp"
#include "verbatim_vector.hpp"

// Forward declaration.
class Face;

/** \brief Vertex class.
 *
 * All vertices consist of position, normal and RGBA color.
 */
class Vertex
{
  public:
    /** Position offset. */
    static const ptrdiff_t POSITION_OFFSET = 0;

    /** Normal offset. */
    static const ptrdiff_t NORMAL_OFFSET = sizeof(Vector3);

    /** Color offset. */
    static const ptrdiff_t COLOR_OFFSET = sizeof(Vector3) + (sizeof(int8_t) * 4);

  private:
    /** Position data. */
    Vector3 m_position;

    /** Normal data. */
    int8_t m_normal[4];

    /** Color data. */
    uint8_t m_color[2];

  public:
    /** \brief Accessor.
     *
     * \return Position data.
     */
    const Vector3& getPosition() const
    {
      return m_position;
    }
    /** \brief Set position data.
     *
     * \param op New position.
     */
    void setPosition(const Vector3 &op)
    {
      m_position = op;
    }

  private:
    /** \brief Setter.
     *
     * \param col Color to set.
     */
    void setColor(const Color &col)
    {
#if defined(COLOR_SPACE_THEFLASH) && COLOR_SPACE_THEFLASH
      float red = col[0]/255.0f;
      float green = col[1]/255.0f;
      float blue = col[2]/255.0f;

      float minc = dnload_fminf(dnload_fminf(red, green), blue);
      float maxc = dnload_fmaxf(dnload_fmaxf(red, green), blue);
      float delta = maxc - minc;

      float lum=(minc+maxc)/2.0f;
      float sat=0.0f;
      float hue=0.0f;

      if (lum > 0.0f && lum < 1.0f)
      {
        float mul = (lum < 0.5f) ? (lum) : (1.0f-lum);
        sat = delta / (mul * 2.0f);
      }

      float maskr = (maxc==red && maxc!=green) ? 1.0f : 0.0f;
      float maskg = (maxc==green && maxc!=blue) ? 1.0f : 0.0f; 
      float maskb = (maxc==blue && maxc!=red) ? 1.0f : 0.0f;

      float addr = ((green-blue)/delta);
      float addg = 2.0f+((blue-red)/delta);
      float addb = 4.0f+((red-green)/delta);

      if(delta>0.0f)
      {
        hue = (maskr*addr + maskg*addg + maskb*addb)/6.0f;
      }

      if(hue<0.0f)
      {
        hue += 1.0f;
      }

      if(hue<(1.0f/255.0f))
      {
        m_color[0] = 0;
        m_color[1] = static_cast<uint8_t>(255*lum);
      }
      else
      {
        m_color[0] = static_cast<uint8_t>(255*hue);
        m_color[1] = static_cast<uint8_t>(255*sat);
      }
#else
      // YUV conversion.
      const float SCALE = 255.0f / 9.0f;
      float fr = static_cast<float>(col[0]) / 255.0f;
      float fg = static_cast<float>(col[1]) / 255.0f;
      float fb = static_cast<float>(col[2]) / 255.0f;
      float mul = 1.0f / (0.299f * fr + 0.587f * fg + 0.114f * fb);
      float nr = fr * mul;
      float ng = fg * mul;
      float nb = fb * mul;
      float writepb = 0.5f * nb - 0.168736f * nr - 0.331264f * ng;
      float writepr = 0.5f * nr - 0.418688f * ng - 0.081312f * nb;
      float convpb = SCALE * (writepb + 4.5f);
      float convpr = SCALE * (writepr + 4.5f);

#if defined(USE_LD)
      if((convpb < 0.0f) || (convpb > 255.5f) || (convpr < 0.0f) || (convpr > 255.0f))
      {
        std::cerr << "color " << col << " not representable\n";
        terminate_program();
      }
#endif

      // Y is discarded since it's normalized out, write U and V.
      m_color[0] = static_cast<uint8_t>(convpb + 0.5f);
      m_color[1] = static_cast<uint8_t>(convpr + 0.5f);

#if 0
      const float INV_SCALE = 9.0f / 255.0f;
      float fu = static_cast<float>(m_color[0]) * INV_SCALE - 4.5f;
      float fv = static_cast<float>(m_color[1]) * INV_SCALE - 4.5f;
      float frr = 1.0f + 1.402f * fv;
      float fgg = 1.0f - 0.344136f * fu - 0.714136f * fv;
      float fbb = 1.0f + 1.772f * fu;
      float mul1 = 1.0f / dnload_fmaxf(dnload_fmaxf(fr, fg), fb);
      float mul2 = 1.0f / dnload_fmaxf(dnload_fmaxf(frr, fgg), fbb);
      std::cout << "[ " << fr * mul1 << " ; " << fg * mul1 << " ; " << fb * mul1 << " ] writes [ " << writeu <<
        " ; " << writev << " ] verbatim [ " << convu << " ; " << convv << " ] reads [ " << fu << " ; " << fv <<
        " ] normalizes to [ " << nr << " ; " << ng << " ; " << nb << " ] becomes [ " << frr * mul2 << " ; " <<
        fgg * mul2 << " ; " << fbb * mul2 << " ]" << std::endl;
#endif
#endif
    }

    /** \brief Convert normal value.
     *
     * \param op Floating point input.
     * \return Signed integer output.
     */
    static int8_t convert_normal_value(float op)
    {
      if(op > 0.0f)
      {
        return static_cast<int8_t>(op * 127.0f + 0.5f);
      }
      return static_cast<int8_t>(op * 128.0f + 0.5f);
    }

    /** \brief Set normal.
     *
     * \param nor Normal to set.
     * \param near_value Near value for vertices.
     */
    void setNormal(const Vector3 &nor, float near_value)
    {
      m_normal[0] = convert_normal_value(nor[0]);
      m_normal[1] = convert_normal_value(nor[1]);
      m_normal[2] = convert_normal_value(nor[2]);
      m_normal[3] = convert_normal_value(near_value);
    }

  public:
    /** \brief Constructor.
     *
     * \param pos Position.
     * \param nor Normal.
     * \param near_value Near value for vertices.
     * \param col Color.
     */
    Vertex(const Vector3 &pos, const Vector3 &nor, float near_value, const Color &col) :
      m_position(pos)
    {
      this->setNormal(nor, near_value);
      this->setColor(col);
    }

#if defined(USE_LD)
  public:
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Output stream.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const Vertex &rhs)
    {
      return lhs << "[" << rhs.getPosition() << ", " << "somenormal" << ", somecolor" << ']';
    }
#endif
};

/** \brief Logical vertex class.
 *
 * Only limited number of faces can attach to a vertex.
 */
class LogicalVertex
{
  public:
    /** Maximum number of attached faces. */
    static const unsigned MAX_VERTEX_FACES = 24;

  private:
    /** Position data. */
    Vector3 m_position;

    /** Normal data. */
    Vector3 m_normal;

    /** Color data. */
    Color m_color;

    /** Face listing. */
    Face *m_face_references[MAX_VERTEX_FACES];

    /** Face count. */
    unsigned m_face_count;

  public:
    /** \brief Add reference to face.
     *
     * \param op Face index.
     */
    void addFaceReference(Face *op)
    {
#if defined(USE_LD)
      if(m_face_count >= MAX_VERTEX_FACES)
      {
        std::cerr << "too many faces connected to a vertex" << std::endl;
        terminate_program();
      }
#endif

      m_face_references[m_face_count] = op;
      ++m_face_count;
    }

    /** \brief Clear face references.
     */
    void clearFaceReferences()
    {
      m_face_count = 0;
    }

    Vector3 & getPosition()
    {
        return m_position;
    }

    const Vector3 & getPosition() const
    {
        return m_position;
    }

    Vector3 & getNormal()
    {
        return m_normal;
    }

    const Vector3 & getNormal() const
    {
        return m_normal;
    }

    Color & getColor()
    {
        return m_color;
    }

    const Color & getColor() const
    {
        return m_color;
    }

  public:
    /** \brief Empty constructor.
     */
    LogicalVertex() { }

    /** \brief Constructor.
     *
     * \param op Vertex content.
     */
    LogicalVertex(const Vector3 & pos, const Color & col) :
      m_position(pos),
      m_color(col),
      m_face_count(0) { }

    /** \brief Empty destructor.
     */
    ~LogicalVertex() { }

  public:
    /** \brief Collapse face references.
     *
     * Calculates normal averaging from face reference normals.
     */
    void collapse();
};

#endif
