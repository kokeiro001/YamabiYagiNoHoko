#pragma once

typedef Graphics::Resource::ITexture Texture;
typedef Graphics::Resource::Text::ITextData TextData;

/// 画像の読み込み、破棄をコントロールする。インスタンスは一つのみ持つ。
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
  
  /// インスタンスを取得する
  static GraphicsManager* GetInst()
	{
		static GraphicsManager inst;
		return &inst;
	}

  /// ゲーム起動時の初期化を行う
	bool OnPowerInit(Graphics::IManager* mgr);

  /// 読み込んだリソースを破棄する
  void Dispose();

	/// 画像を読み込む(上書き有り)
  /// @param path 読み込む画像のファイルパス
  /// @param name 読み込んだ画像を使用する際のエイリアス
	void LoadTexture(const std::string path, const std::string name);

	/// 画像を読み込む(上書き無し)
  /// @param path 読み込む画像のファイルパス
  /// @param name 読み込んだ画像を使用する際のエイリアス
  void LoadTexture2(const std::string path, const std::string name);

	/// フォントを読み込む
  /// @param path 読み込むフォントデータのファイルパス
  /// @param fontName 読み込んだフォントの名前
  /// @param registerName 読み込んだフォントを使用する際のエイリアス
	void LoadFont(const std::string path, const std::string fontName, const std::string registName);

  /// 指定した名前の画像を取得する
	Texture* GetTexture(const std::string name);

  /// 指定した名前の画像の大きさを取得する
	Point2DI GetTextureSize(const std::string name);

  /// フォント、文字サイズを指定してテキストレンダラーを取得する
	Graphics::Simple::ITextRenderer* GetTextRenderer(std::string font, int size);

  /// テキスト描画用データを取得する
	TextData* GetTextData(std::string font);

  /// 指定した名前の画像を破棄する
	void RemoveTexture(const std::string name);

  /// 読み込んだ画像を全て破棄する
	void ClearTexture();

	Graphics::IManager* GetSeleneGrMgr() { return m_pManager; }
	Graphics::Simple::ISpriteRenderer* GetSprite() { return m_pSprite; };

	/// Luaで使用する機能を登録する
	static void RegistLua();
};
