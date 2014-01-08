#pragma once

// Z‚ª‚Å‚©‚¢‚Ù‚Ç‰œ‚É
enum DrawPosType
{
	DRAWPOS_ABSOLUTE,
	DRAWPOS_RELATIVE,
};

enum TextureDivType
{
	TEX_DIVTYPE_NONE,
	TEX_DIVTYPE_SIMPLE,
	TEX_DIVTYPE_USER,
};

class Sprite
	: public boost::enable_shared_from_this<Sprite>
{
protected:
	static const int MAX_TEXT = 256;

	typedef std::list<boost::shared_ptr<Sprite>>::iterator Itr;

	enum Mode{
		SPR_NONE,
		SPR_TEXTURE,
		SPR_TEXT,
	};

	Mode m_mode;
	bool m_isDraw;
	DrawPosType m_posType;

	std::string m_name;

	float m_x;
	float m_y;
	float m_z;
	float m_alpha;

	float m_width;
	float m_height;
	float m_drawWidth;
	float m_drawHeight;

	float m_centerX;
	float m_centerY;
	float m_rot;
	float m_rotOffcetX;
	float m_rotOffcetY;

	Engine::Graphics::Resource::ITexture* m_pTexBuf;
	ColorF m_textureColor;
	TextureDivType m_divType;
	// simple div
	int m_divDrawTexIdx;
	int m_divX, m_divY;
	int m_divW, m_divH;

	// user div
	int m_srcX, m_srcY;
	int m_srcW, m_srcH;

	// text data
	bool m_useTextRenderer;
	Engine::Graphics::Simple::ITextRenderer* m_pTextRdr;
	Graphics::Resource::Text::ITextData* m_pTextData;
	wchar_t m_text[MAX_TEXT];
	ColorF m_textColor;
	std::string m_fontName;
	int m_fontSize;

	boost::weak_ptr<Sprite> m_pParent;
	std::list<boost::shared_ptr<Sprite>> m_children;

	void UpdateSize();
public:
	Sprite();
	virtual ~Sprite();

	boost::shared_ptr<Sprite> GetPtr() {
    return shared_from_this();
  }

	void SetPos(float x, float y) {
		m_x = x;
		m_y = y;
	}
	void SetPos(float x, float y, float z) {
		m_x = x;
		m_y = y;
		m_z = z;
	}

	std::string const GetName() { return m_name; }
	void				SetName(std::string name) { m_name = name; }

	float const GetX() { return m_x; }
	void				SetX(float x) { m_x = x; }

	float const GetY() { return m_y; }
	void				SetY(float y) { m_y = y; }
	
	float const GetZ() { return m_z; }
	void				SetZ(float z) { m_z = z; }
	
	float const GetAlpha() { return m_alpha; }
	void				SetAlpha(float alpha);
	
	float const GetWidth() { return m_width; }
	void				SetWidth(float width) { m_width = width; }

	float const GetHeight() { return m_height; }
	void				SetHeight(float height) { m_height = height; }

	Point2DI		GetOriginTexSize();

	float const GetDrawWidth() { return m_drawWidth; }
	void				SetDrawWidth(float width) { m_drawWidth = width; }

	float const GetDrawHeight() { return m_drawHeight; }
	void				SetDrawHeight(float height) { m_drawHeight = height; }

	void	SetCenter(float x, float y) 
	{
		m_centerX = x; 
		m_centerY = y; 
	}

	float const GetCenterX() { return m_centerX; }
	void				SetCenterX(float x) { m_centerX = x; }

	float const GetCenterY() { return m_centerY; }
	void				SetCenterY(float y) { m_centerY = y; }

	float const GetRot() { return m_rot; }
	void				SetRot(float rot) { m_rot = rot; }

	float const GetRotOffcetX() { return m_rotOffcetX; }
	void				SetRotOffcetX(float x) { m_rotOffcetX = x; }

	float const GetRotOffcetY() { return m_rotOffcetY; }
	void				SetRotOffcetY(float y) { m_rotOffcetY = y; }

	int const GetDivDrawTexIdx() { return m_divDrawTexIdx; }
	void			SetDivDrawTexIdx(int idx) { m_divDrawTexIdx = idx; }

	bool IsDraw() const { return m_isDraw; }
	void Show() { m_isDraw = true; }
	void Hide() { m_isDraw = false; }

	void SetDrawPosAbsolute() { m_posType = DRAWPOS_ABSOLUTE; }
	void SetDrawPosRelative() { m_posType = DRAWPOS_RELATIVE; }

	void SetTextureMode(const char* name);
	void SetDivTextureMode(const char* name, int xnum, int ynum, int width, int height);
	void SetTextureSrc(int x, int y, int w, int h);
	void SetTextureColorF(ColorF color);
	
	void SetTextMode(const char* text);
	void SetTextMode2(const char* text, const char* font);
	void SetText(const char* text);
	std::string GetText();
	void SetTextColorF(ColorF color);
	void SetTextColor1(float r, float g, float b);
	void SetTextColor255(int r, int g, int b);
	void SetFontSize(int size);


	void AddChild(boost::shared_ptr<Sprite> chr);
	void RemoveChild(boost::shared_ptr<Sprite> chr);
	void ClearChild();
	void SetParent(boost::shared_ptr<Sprite> parent) { m_pParent = parent; }
	void RemoveFromParent();
	void RemoveFromParentForce();
	int GetChildCnt() { return m_children.size(); }
	boost::shared_ptr<Sprite> GetChild(int idx);

	void DrawThis(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY);
	void Draw(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY, int level);
	void SortZ();

	RectI GetBounds() { return RectI(m_x, m_y, m_width, m_height); }

	static void RegistLua();
};



class DrawSystem
{
	boost::shared_ptr<Sprite> m_baseSprite;
	std::vector<boost::shared_ptr<Sprite>> m_sprites;
public:
	bool OnPowerInit();
	static DrawSystem* GetInst()
	{
		static DrawSystem inst;
		return &inst;
	}
	void Dispose();

	boost::shared_ptr<Sprite> GetSprite();
	void AddSprite(boost::shared_ptr<Sprite> spr);
	void RemoveSprite(boost::shared_ptr<Sprite> spr);
	void ClearSprite();

	void Draw();

	static void RegistLua();
};

