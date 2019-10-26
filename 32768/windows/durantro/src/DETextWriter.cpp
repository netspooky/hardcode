// -------------------------------------------------------------------------------------
// File:        DETextWriter.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "DETextWriter.h"
#include "TextTexture.h"

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

#define LIGHT_TIME     50
#define LIGHT_SPEED(a) ((a)*255/LIGHT_TIME)

struct TFontRef
{
  const char *pszFont;
  byte size;
  bool bBold;
  bool bItalic;
};

enum
{
  FNARIAL40,
  FNARIAL60,
  FNARIAL80,
  FNLUCID60,
  FNLUCID90,
  FNBOOK100,
  FNBOOK_60,
  FNARIAL30,
};

static TFontRef s_aFontRef[] =
{
  { "Arial", 40, true, true },
  { "Arial", 60, false, true },
  { "Arial", 80, true, true },
  { "Lucida", 60, true, true },
  { "Lucida", 90, true, true },
  { "Book Antiqua", 80, true, true },
  { "Book Antiqua", 60, true, true },
  { "Arial", 30, true, false },
};

struct TPhraseDef
{
  word time;
  short x, y;
  char dx, dy;
  byte fontRef;   // /100;
  byte fadeTime;
  int length;
  unsigned color;
  const char *pszText;
};

static TPhraseDef s_TText[] =
{
  // delay    x    y   vx  vy       font  fade length     color   text   
  // ---------------------------------------------------------------------

  {     50,  20,  10,  10,  3, FNLUCID90,  250,   700, 0x80FFA0, "Iguana" },
  {      0, 110, 300, -10, -3, FNLUCID90,  250,   700, 0x80FFA0, "Chanka" },
  {    450, 200, 180, -10, -3, FNARIAL60,  150,   400, 0xA0A030, "present" },
  {    250,  20, 300,   2, -7, FNBOOK100,  250,  1000, 0xA0E0FF, "Durantro" },
  {   1150,  20, 270,  15,  3, FNARIAL30,   30,   300, 0xF0F0F0, "A 20K production" },
  {    300, 120, 370, -15, -3, FNARIAL30,   30,   300, 0xF0F0F0, "for Durango Party'01" },

  {    500, 250, 240,   0, 60, FNARIAL30,   30,   200, 0xFF8040, "Code" },
  {    150,  20, 370,  35, -3, FNARIAL30,   30,   500, 0xFFFF00, "una-i" },
  {      0, 540, 370, -35, -3, FNARIAL30,   30,   500, 0xFFFF00, "Jare" },

  {    600, 240, 440,   0,-60, FNARIAL30,   50,   200, 0xFF8040, "Music" },
  {      0, 240, 240,   0, 60, FNARIAL30,   50,   200, 0xFFFF00, "Smash" },
  {    150, 240, 440,   0,-60, FNARIAL30,  100,   300, 0xFF8040, "Support" },
  {      0, 240, 240,   0, 60, FNARIAL30,  100,   300, 0xFFFF00, "OLS" },

  {   1500, 220,  60, -10, -6, FNBOOK_60,   30,  1500, 0xFF8040, "Greetings" },
  
  {    300, 460, 350,-128, -3, FNARIAL40,   30,   300, 0xFFFF00, "Taberna Zarra" },

  {    300, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Chanka" },
  {    200, 520, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "CoD" },
  {    200, 460, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Elerium Core" },
  {    200, 520, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "glue" },
  {    200, 480, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Honkurai" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Iguana" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Niako" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Ozone" },
  {    200, 510, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "RGBA" },
  {    200, 520, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "SOS" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Synth" },

  {    200, 480, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Anaconda" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Concept" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Fuzzion" },
  {    200, 480, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Incognita" },
  {    200, 500, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Solstice" },
  {    200, 460, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "Three Pixels" },
  {    200, 520, 370, -95, -3, FNARIAL30,   30,   200, 0xFFFF00, "TLOTB" },

  {   1200, 160, 370, -3, -3, FNARIAL30,   300,  1200, 0xFFFF00, "That's all folks!" },
};

struct CDETextWriter::TPhrase
{
  TPhraseDef *pDef;
  int elapsed;
  unsigned color;
  CTextTexture Text;
};

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CDETextWriter::Init  (CDisplayDevice *pDev)
{
  End();

  inherited::Init(pDev);
  m_Lista.Init();
  m_iFrase = 0;
  m_elapsed = s_TText[0].time;
  return RET_OK;
}


// --------------------------------------------------------------------------
// Function:      End
// Purpose:       Release all resources and deinitialize the object
// Parameters:    
// --------------------------------------------------------------------------
void CDETextWriter::End  ()
{
  if (IsOk())
  {
    TLinkedListNode<TPhrase*> *pNode = m_Lista.GetHead();
    while (pNode)
    {
      TLinkedListNode<TPhrase*> *pNext = pNode->pNext;

      DISPOSE(pNode->t);
      m_Lista.Remove(pNode);

      pNode = pNext;
    }
    inherited::End();

  }
}

// --------------------------------------------------------------------------
// Function:      Run
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CDETextWriter::Run         (int time)
{
  inherited::Run(time);
  int delta = m_delta;
  if (delta > 0)
  {
    //  Gather new phrases.
    m_elapsed -= delta;
    while (m_elapsed <= 0)
    {
      if (m_iFrase < ARRAY_LEN(s_TText))
      {
        TPhrase *pFrase = NEW(TPhrase);
        pFrase->pDef = s_TText + m_iFrase;
        pFrase->elapsed = -m_elapsed;
        const TFontRef &font = s_aFontRef[s_TText[m_iFrase].fontRef];
        if (RET_OK == pFrase->Text.Init(m_pDev) && pFrase->Text.AddText(s_TText[m_iFrase].pszText, font.pszFont, font.size, font.bBold, font.bItalic))
          m_Lista.AddFirst(pFrase);
        else
          DISPOSE(pFrase);
        pFrase->color = s_TText[m_iFrase].color;
        m_iFrase = m_iFrase + 1;
        if (m_iFrase < ARRAY_LEN(s_TText))
          m_elapsed += s_TText[m_iFrase].time;
      }
      if (m_iFrase >= ARRAY_LEN(s_TText))
        m_elapsed = 1 << 30;
    }

    // Advance the currently running phrases.
    TLinkedListNode<TPhrase*> *pNode = m_Lista.GetHead();
    while (pNode)
    {
      TLinkedListNode<TPhrase*> *pNext = pNode->pNext;

      // Time passes...
      pNode->t->elapsed += delta;
      if (pNode->t->elapsed >= pNode->t->pDef->length)
      {
        DISPOSE(pNode->t);
        m_Lista.Remove(pNode);
      }

      pNode = pNext;
    }
  }

  return m_Lista.GetCount() || m_iFrase < ARRAY_LEN(s_TText);
}

// --------------------------------------------------------------------------
// Function:      Draw
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDETextWriter::Draw        (CRenderContext &rc) const
{
  if (!IsOk())
    return;

  // Draw the currently running phrases.
  TLinkedListNode<TPhrase*> *pNode = m_Lista.GetHead();
  while (pNode)
  {
    float k = float(pNode->t->elapsed)*.01f;
    float x = float(pNode->t->pDef->x) + k*pNode->t->pDef->dx;
    float y = float(pNode->t->pDef->y) + k*pNode->t->pDef->dy;

    unsigned c;
    if (pNode->t->elapsed < pNode->t->pDef->fadeTime)
      c = (pNode->t->elapsed)*255/pNode->t->pDef->fadeTime;
    else if (pNode->t->elapsed > (pNode->t->pDef->length - pNode->t->pDef->fadeTime))
      c = (pNode->t->pDef->length - pNode->t->elapsed)*255/pNode->t->pDef->fadeTime;
    else
      c = 255;
    pNode->t->Text.Draw(rc, c << 24 | pNode->t->color, x, y);

    pNode = pNode->pNext;
  }
}

