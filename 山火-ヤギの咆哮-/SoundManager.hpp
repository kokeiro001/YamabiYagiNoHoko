#pragma once

/// BGM�E���ʉ��̓ǂݍ��݁A�j�����R���g���[������B�C���X�^���X�͈�̂ݎ��B
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
  
  /// �C���X�^���X���擾����
	static SoundManager* GetInst()
	{
		static SoundManager inst;
		return &inst;
	}

  /// �Q�[���N�����̏��������s��
	bool OnPowerInit(Engine::Sound::IManager* mgr);

  /// �ǂݍ��񂾃��\�[�X��j������
	void Dispose();

	/// ���ʉ���ǂݍ���(�㏑���L��)
  /// @param path �ǂݍ��ތ��ʉ��t�@�C���̃p�X
  /// @param name �ǂݍ��񂾌��ʉ����g�p����ۂ̃G�C���A�X
	void LoadSe(const char* path, const char* name);

	/// ���ʉ����Đ�����
  void PlaySe(const char* name);

	/// ���ʉ��̍Đ����ʂ�ݒ肷��
  void SetSeVol(const char* name, float vol);

	/// �w�肵���p�X�̉����t�@�C����BGM�Ƃ��čĐ�����
	void PlayBgm(const char* path);

	/// BGM�̍Đ����ʂ�ݒ肷��
  void SetBgmVol(float vol);

	/// �Đ�����BGM���~����
  void StopBgm();

	/// ���������̍X�V���s���B�P�t���[�����ƂɌĂяo���Ă��������B
	void Update();

	/// Lua�Ŏg�p����@�\��o�^����
	static void RegistLua();
};

