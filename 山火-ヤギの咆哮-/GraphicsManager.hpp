#pragma once


class GraphicsManager
{
	typedef Graphics::Resource::ITexture Texture;

	typedef std::map<std::string, Texture*> TextureMap;
	typedef std::map<std::string, Texture*>::iterator TextureMapItr;
	typedef std::pair<std::string, Texture*> TextureMapPair;

	TextureMap m_textures;
	std::map<std::string, std::map<int, Graphics::Simple::ITextRenderer*>> m_textRenderers;

	Graphics::IManager* m_pManager;
	Graphics::Simple::ISpriteRenderer* m_pSprite;

	GraphicsManager(void);
	~GraphicsManager(void);

	void CreateSimpleTextures();


public:
	bool OnPowerInit(Graphics::IManager* mgr);
	void Dispose();
	static GraphicsManager* GetInst()
	{
		static GraphicsManager inst;
		return &inst;
	}

	/// 上書き有りのロード
	void LoadTexture(const std::string path, const std::string name);
	/// 上書き無しのロード
	void LoadTexture2(const std::string path, const std::string name);

	Texture* GetTexture(const std::string name);
	Point2DI GetTextureSize(const std::string name);
	Graphics::Simple::ITextRenderer* GetTextRenderer(std::string font, int size);

	void RemoveTexture(const std::string name);
	void ClearTexture();

	Graphics::IManager* GetSeleneGrMgr() { return m_pManager; }
	Graphics::Simple::ISpriteRenderer* GetSprite() { return m_pSprite; };

	static void RegistLua();
};
