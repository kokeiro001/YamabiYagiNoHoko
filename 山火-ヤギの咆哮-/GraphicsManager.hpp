#pragma once

typedef Graphics::Resource::ITexture Texture;
typedef Graphics::Resource::Text::ITextData TextData;

/// �摜�̓ǂݍ��݁A�j�����R���g���[������B�C���X�^���X�͈�̂ݎ��B
class GraphicsManager
{

	typedef std::map<std::string, Texture*> TextureMap;
	typedef std::map<std::string, Texture*>::iterator TextureMapItr;
	typedef std::pair<std::string, Texture*> TextureMapPair;

	typedef std::pair<std::string, TextData*> TextMapPair;

	TextureMap m_textures;
	std::map<std::string, std::map<int, Graphics::Simple::ITextRenderer*>> m_textRenderers;

	std::map<std::string, TextData*> m_texts;

	Graphics::IManager* m_pManager;
	Graphics::Simple::ISpriteRenderer* m_pSprite;

	GraphicsManager(void);
	~GraphicsManager(void);

	void CreateSimpleTextures();

public:
  
  /// �C���X�^���X���擾����
  static GraphicsManager* GetInst()
	{
		static GraphicsManager inst;
		return &inst;
	}

  /// �Q�[���N�����̏��������s��
	bool OnPowerInit(Graphics::IManager* mgr);

  /// �ǂݍ��񂾃��\�[�X��j������
  void Dispose();

	/// �摜��ǂݍ���(�㏑���L��)
  /// @param path �ǂݍ��މ摜�̃t�@�C���p�X
  /// @param name �ǂݍ��񂾉摜���g�p����ۂ̃G�C���A�X
	void LoadTexture(const std::string path, const std::string name);

	/// �摜��ǂݍ���(�㏑������)
  /// @param path �ǂݍ��މ摜�̃t�@�C���p�X
  /// @param name �ǂݍ��񂾉摜���g�p����ۂ̃G�C���A�X
  void LoadTexture2(const std::string path, const std::string name);

	/// �t�H���g��ǂݍ���
  /// @param path �ǂݍ��ރt�H���g�f�[�^�̃t�@�C���p�X
  /// @param fontName �ǂݍ��񂾃t�H���g�̖��O
  /// @param registerName �ǂݍ��񂾃t�H���g���g�p����ۂ̃G�C���A�X
	void LoadFont(const std::string path, const std::string fontName, const std::string registName);

  /// �w�肵�����O�̉摜���擾����
	Texture* GetTexture(const std::string name);

  /// �w�肵�����O�̉摜�̑傫�����擾����
	Point2DI GetTextureSize(const std::string name);

  /// �t�H���g�A�����T�C�Y���w�肵�ăe�L�X�g�����_���[���擾����
	Graphics::Simple::ITextRenderer* GetTextRenderer(std::string font, int size);

  /// �e�L�X�g�`��p�f�[�^���擾����
	TextData* GetTextData(std::string font);

  /// �w�肵�����O�̉摜��j������
	void RemoveTexture(const std::string name);

  /// �ǂݍ��񂾉摜��S�Ĕj������
	void ClearTexture();

	Graphics::IManager* GetSeleneGrMgr() { return m_pManager; }
	Graphics::Simple::ISpriteRenderer* GetSprite() { return m_pSprite; };

	/// Lua�Ŏg�p����@�\��o�^����
	static void RegistLua();
};
