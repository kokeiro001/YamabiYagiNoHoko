#pragma once

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
	bool OnPowerInit(Engine::Sound::IManager* mgr);
	static SoundManager* GetInst()
	{
		static SoundManager inst;
		return &inst;
	}
	void Dispose();

	/// ã‘‚«—L‚è‚ÅŒø‰Ê‰¹‚ğƒ[ƒh‚·‚é
	void LoadSe(const char* path, const char* name);
	void PlaySe(const char* name);
	void SetSeVol(const char* name, float vol);

	void PlayBgm(const char* path);
	void SetBgmVol(float vol);
	void StopBgm();

	void Update();

	static void RegistLua();
};

