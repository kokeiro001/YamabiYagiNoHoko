#pragma once

// Z���ł����قǉ���

/// �X�v���C�g�̕`����W������
enum DrawPosType
{
	DRAWPOS_ABSOLUTE, ///< �E�B���h�E����̐�΍��W
	DRAWPOS_RELATIVE, ///< �e�X�v���C�g����̑��΍��W
};

/// �e�N�X�`���̓���������@������
enum TextureDivType
{
	TEX_DIVTYPE_NONE, ///< �������Ȃ�
	TEX_DIVTYPE_SIMPLE, ///< ����������
	TEX_DIVTYPE_USER, ///< ���[�U�[���w�肵����`�Q�ŕ�������
};

/// �X�v���C�g�@�\��񋟂���
class Sprite
	: public boost::enable_shared_from_this<Sprite>
{
protected:
	static const int MAX_TEXT = 256;

	typedef std::list<boost::shared_ptr<Sprite>>::iterator Itr;

  /// �\�����[�h������
	enum Mode{
		SPR_NONE,     /// ��\��
		SPR_TEXTURE,  /// �e�N�X�`���`��
		SPR_TEXT,     /// �e�L�X�g�`��
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

  /// �ݒ肳�ꂽ�e�N�X�`������p���āA���g���ێ�����傫���̏����X�V����B
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

	bool IsDraw() const { return m_isDraw; }  ///< �\���E��\���̏�Ԃ��擾����
	void Show() { m_isDraw = true; }  ///< �`�悷���Ԃɂ���
	void Hide() { m_isDraw = false; } ///< �`�悵�Ȃ���Ԃɂ���

  /// �E�B���h�E����̐�΍��W�ŕ`�悷���Ԃɂ���
	void SetDrawPosAbsolute() { m_posType = DRAWPOS_ABSOLUTE; }

  /// �e�X�v���C�g����̑��΍��W�ŕ`�悷���Ԃɂ���
  void SetDrawPosRelative() { m_posType = DRAWPOS_RELATIVE; }

  /// �w�肵���G�C���A�X�̃e�N�X�`����p���āA�`�惂�[�h���e�N�X�`���ɐݒ肷��
	void SetTextureMode(const char* name);

  /// �����������e�N�X�`����`�悷�郂�[�h�̐ؑւ���
  /// @param name �e�N�X�`���̃G�C���A�X
  /// @param xnum X�����̕�����
  /// @param ynum Y�����̕�����
  /// @param width ������̃e�N�X�`���̕�(���Z�ɂ��덷�̉e����}���邽�߂ɕK�v)
  /// @param height ������̃e�N�X�`���̍���(���Z�ɂ��덷�̉e����}���邽�߂ɕK�v)
	void SetDivTextureMode(const char* name, int xnum, int ynum, int width, int height);

  /// �e�N�X�`����`�悷��ہA�`��Ɏg�p����͈͂��w�肷��
	void SetTextureSrc(int x, int y, int w, int h);

  void SetTextureColorF(ColorF color);  ///< �e�N�X�`���̕`��F��ݒ肷��
	

  /// �e�L�X�g�`�惂�[�h�ɂ���
	void SetTextMode(const char* text);

  /// �t�H���g���w�肵�ăe�L�X�g�`�惂�[�h�ɂ���
  void SetTextMode2(const char* text, const char* font);

  /// �`�悷��e�L�X�g��ݒ肷��
	void SetText(const char* text);

  /// �e�L�X�g���擾����
  std::string GetText();
	void SetTextColorF(ColorF color);               ///< �e�L�X�g�̕`��F��ݒ肷��
	void SetTextColor1(float r, float g, float b);  ///< �e�L�X�g�̕`��F��ݒ肷��(0.0-1.0)
	void SetTextColor255(int r, int g, int b);      ///< �e�L�X�g�̕`��F��ݒ肷��(0-255)
	void SetFontSize(int size);                     ///< �e�L�X�g�`��̃t�H���g�T�C�Y��ݒ肷��


	void AddChild(boost::shared_ptr<Sprite> chr);   ///< �q�X�v���C�g��ǉ�����
	void RemoveChild(boost::shared_ptr<Sprite> chr);///< �q�X�v���C�g���폜����
	void ClearChild();                              ///< �q�X�v���C�g��S�č폜����

	void SetParent(boost::shared_ptr<Sprite> parent) { m_pParent = parent; }  ///< �e�X�v���C�g��ݒ肷��
	void RemoveFromParent();      ///< �e�X�v���C�g���玩�g��؂藣��
	void RemoveFromParentForce(); ///< �e�X�v���C�g���玩�g�������I�ɐ؂藣��(��{�I�ɌĂяo���Ȃ�����)
	int GetChildCnt() { return m_children.size(); } ///< �q�X�v���C�g�̐����擾����
	boost::shared_ptr<Sprite> GetChild(int idx);    ///< �q�X�v���C�g���擾����

  /// ���g��`�悷��
	void DrawThis(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY);

  /// �q�X�v���C�g���܂߂ĕ`�悷��
	void Draw(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY, int level);

  /// �q�X�v���C�g��Z���W�Ń\�[�g����(Z���W���������قǎ�O�ɕ`�悳���)
	void SortZ();

  /// �`��̈�̑傫�����擾����
	RectI GetBounds() { return RectI((int)m_x, (int)m_y, (int)m_width, (int)m_height); }

	/// Lua�Ŏg�p����@�\��o�^����
	static void RegistLua();
};


/// �`��V�X�e����񋟂���
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

