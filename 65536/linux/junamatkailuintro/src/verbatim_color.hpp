#ifndef VERBATIM_COLOR_HPP
#define VERBATIM_COLOR_HPP

#include "verbatim_realloc.hpp"

/** RGBA color class.
 */
class Color
{
  private:
    /** Color data. */
    uint8_t m_data[4];

  public:
    /** \brief Accessor.
     *
     * \return Data.
     */
    const uint8_t* getData() const
    {
      return m_data;
    }

    /** \brief Access operator.
     *
     * \return Value.
     */
    uint8_t& operator[](const int idx)
    {
      return m_data[idx];
    }

    /** \brief Const access operator.
     *
     * \return Value.
     */
    const uint8_t& operator[](const int idx) const
    {
      return m_data[idx];
    }

  public:
    /** \brief Empty constructor.
     */
    Color() { }

    /** \brief Constructor.
     *
     * \param cr Red component.
     * \param cg Green component.
     * \param cb Blue component.
     * \param ca Alpha component.
     */
    Color(uint8_t cr, uint8_t cg, uint8_t cb, uint8_t ca)
    {
      m_data[0] = cr;
      m_data[1] = cg;
      m_data[2] = cb;
      m_data[3] = ca;
    }

  private:
    /** \brief Mix two color element values.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \param ratio Mixing ratio.
     * \return Modulated value.
     */
    static uint8_t mix_color_element(uint8_t lhs, uint8_t rhs, float ratio)
    {
      float c1 = static_cast<float>(lhs);
      float c2 = static_cast<float>(rhs);
      float ret = dnload_fminf(dnload_fmaxf((c2 - c1) * ratio + c1, 0.0f), 255.0f);
      return static_cast<uint8_t>(ret + 0.5f);
    }

    /** \brief Modulate two color element values.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Modulated value.
     */
    static uint8_t modulate_color_element(uint8_t lhs, uint8_t rhs)
    {
      float ret = (static_cast<float>(lhs) / 255.0f) * (static_cast<float>(rhs) / 255.0f);
      return static_cast<uint8_t>((ret * 255.0f) + 0.5f);
    }

  public:
    /** \brief Mix two colors.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \param ratio Mixing ratio.
     * \return Result color.
     */
    friend Color mix(const Color &lhs, const Color &rhs, float ratio)
    {
      return Color(mix_color_element(lhs[0], rhs[0], ratio),
          mix_color_element(lhs[1], rhs[1], ratio),
          mix_color_element(lhs[2], rhs[2], ratio),
          mix_color_element(lhs[3], rhs[3], ratio));
    }

    /** \brief Modulate two colors.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Result color.
     */
    friend Color modulate(const Color &lhs, const Color &rhs)
    {
      return Color(modulate_color_element(lhs[0], rhs[0]),
          modulate_color_element(lhs[1], rhs[1]),
          modulate_color_element(lhs[2], rhs[2]),
          modulate_color_element(lhs[3], rhs[3]));
    }

#if defined(USE_LD)
    /** \brief Print operator.
     *
     * \param lhs Left-hand-side operand.
     * \param rhs Right-hand-side operand.
     * \return Output stream.
     */
    friend std::ostream& operator<<(std::ostream &lhs, const Color &rhs)
    {
      return lhs << "[ " << static_cast<unsigned>(rhs[0]) << " ;  " << static_cast<unsigned>(rhs[1]) <<
        " ; " << static_cast<unsigned>(rhs[2]) << " ; " << static_cast<unsigned>(rhs[3]) << " ]";
    }
#endif
};

#endif
