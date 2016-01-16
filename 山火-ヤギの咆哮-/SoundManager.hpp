#pragma once

/// BGM・効果音の読み込み、破棄をコントロールする。インスタンスは一つのみ持つ。
class SoundManager
{
	static const int MAX_SE_LAYER = 20;
	typedef Selene::Engine::Sound::Resource::IStaticSound Se;
	typedef std::map<std::string, Se*>::value_type SePair;
	typedef std::map<std::string, Se*>::iterator SeItr;
	typedef Engine::Sound::Resource::IStreamSound Bgm;

	Engine::Sound::IManager* m_pManager;

	std::map<std::string, Se*> m_seMap;

	Bgm* m_pCurrentBgm;

	SoundManager(void);
	~SoundManager(void);

public:
  
  /// インスタンスを取得する
	static SoundManager* GetInst()
	{
		static SoundManager inst;
		return &inst;
	}

  /// ゲーム起動時の初期化を行う
	bool OnPowerInit(Engine::Sound::IManager* mgr);

  /// 読み込んだリソースを破棄する
	void Dispose();

	/// 効果音を読み込む(上書き有り)
  /// @param path 読み込む効果音ファイルのパス
  /// @param name 読み込んだ効果音を使用する際のエイリアス
	void LoadSe(const char* path, const char* name);

	/// 効果音を再生する
  void PlaySe(const char* name);

	/// 効果音の再生音量を設定する
  void SetSeVol(const char* name, float vol);

	/// 指定したパスの音声ファイルをBGMとして再生する
	void PlayBgm(const char* path);

	/// BGMの再生音量を設定する
  void SetBgmVol(float vol);

	/// 再生中のBGMを停止する
  void StopBgm();

	/// 内部処理の更新を行う。１フレームごとに呼び出してください。
	void Update();

	/// Luaで使用する機能を登録する
	static void RegistLua();
};

