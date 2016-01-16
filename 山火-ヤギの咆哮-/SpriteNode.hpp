#pragma once

// Zがでかいほど奥に

/// スプライトの描画座標を示す
enum DrawPosType
{
	DRAWPOS_ABSOLUTE, ///< ウィンドウからの絶対座標
	DRAWPOS_RELATIVE, ///< 親スプライトからの相対座標
};

/// テクスチャの内部分割手法を示す
enum TextureDivType
{
	TEX_DIVTYPE_NONE, ///< 分割しない
	TEX_DIVTYPE_SIMPLE, ///< 等分割する
	TEX_DIVTYPE_USER, ///< ユーザーが指定した矩形群で分割する
};

/// スプライト機能を提供する
class Sprite
	: public boost::enable_shared_from_this<Sprite>
{
protected:
	static const int MAX_TEXT = 256;

	typedef std::list<boost::shared_ptr<Sprite>>::iterator Itr;

  /// 表示モードを示す
	enum Mode{
		SPR_NONE,     /// 非表示
		SPR_TEXTURE,  /// テクスチャ描画
		SPR_TEXT,     /// テキスト描画
	};

	Mode m_mode;
	bool m_isDraw;
	DrawPosType m_posType;

	std::string m_name;

	float m_alpha;

  // position
	float m_x;
	float m_y;
	float m_z;

  // size
	float m_width;
	float m_height;
	float m_drawWidth;
	float m_drawHeight;

  // draw params
	float m_centerX;
	float m_centerY;
	float m_rot;
	float m_rotOffcetX;
	float m_rotOffcetY;

	// simple div
	int m_divDrawTexIdx;
	int m_divX, m_divY;
	int m_divW, m_divH;

	// user div
	int m_srcX, m_srcY;
	int m_srcW, m_srcH;

  // texture params
	Engine::Graphics::Resource::ITexture* m_pTexBuf;
	ColorF m_textureColor;
	TextureDivType m_divType;

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

  /// 設定されたテクスチャ情報を用いて、自身が保持する大きさの情報を更新する。
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

	ColorF const	GetColor();
	void					SetColor(ColorF color);

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

	bool IsDraw() const { return m_isDraw; }  ///< 表示・非表示の状態を取得する
	void Show() { m_isDraw = true; }  ///< 描画する状態にする
	void Hide() { m_isDraw = false; } ///< 描画しない状態にする

  /// ウィンドウからの絶対座標で描画する状態にする
	void SetDrawPosAbsolute() { m_posType = DRAWPOS_ABSOLUTE; }

  /// 親スプライトからの相対座標で描画する状態にする
  void SetDrawPosRelative() { m_posType = DRAWPOS_RELATIVE; }

  /// 指定したエイリアスのテクスチャを用いて、描画モードをテクスチャに設定する
	void SetTextureMode(const char* name);

  /// 等分割したテクスチャを描画するモードの切替える
  /// @param name テクスチャのエイリアス
  /// @param xnum X方向の分割数
  /// @param ynum Y方向の分割数
  /// @param width 分割後のテクスチャの幅(除算による誤差の影響を抑えるために必要)
  /// @param height 分割後のテクスチャの高さ(除算による誤差の影響を抑えるために必要)
	void SetDivTextureMode(const char* name, int xnum, int ynum, int width, int height);

  /// テクスチャを描画する際、描画に使用する範囲を指定する
	void SetTextureSrc(int x, int y, int w, int h);

  void SetTextureColorF(ColorF color);  ///< テクスチャの描画色を設定する
	

  /// テキスト描画モードにする
	void SetTextMode(const char* text);

  /// フォントを指定してテキスト描画モードにする
  void SetTextMode2(const char* text, const char* font);

  /// 描画するテキストを設定する
	void SetText(const char* text);

  /// テキストを取得する
  std::string GetText();
	void SetTextColorF(ColorF color);               ///< テキストの描画色を設定する
	void SetTextColor1(float r, float g, float b);  ///< テキストの描画色を設定する(0.0-1.0)
	void SetTextColor255(int r, int g, int b);      ///< テキストの描画色を設定する(0-255)
	void SetFontSize(int size);                     ///< テキスト描画のフォントサイズを設定する


	void AddChild(boost::shared_ptr<Sprite> chr);   ///< 子スプライトを追加する
	void RemoveChild(boost::shared_ptr<Sprite> chr);///< 子スプライトを削除する
	void ClearChild();                              ///< 子スプライトを全て削除する

	void SetParent(boost::shared_ptr<Sprite> parent) { m_pParent = parent; }  ///< 親スプライトを設定する
	void RemoveFromParent();      ///< 親スプライトから自身を切り離す
	void RemoveFromParentForce(); ///< 親スプライトから自身を強制的に切り離す(基本的に呼び出さないこと)
	int GetChildCnt() { return m_children.size(); } ///< 子スプライトの数を取得する
	boost::shared_ptr<Sprite> GetChild(int idx);    ///< 子スプライトを取得する

  /// 自身を描画する
	void DrawThis(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY);

  /// 子スプライトを含めて描画する
	void Draw(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY, int level);

  /// 子スプライトをZ座標でソートする(Z座標が小さいほど手前に描画される)
	void SortZ();

  /// 描画領域の大きさを取得する
	RectI GetBounds() { return RectI((int)m_x, (int)m_y, (int)m_width, (int)m_height); }

	/// Luaで使用する機能を登録する
	static void RegistLua();
};


/// 描画システムを提供する
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

