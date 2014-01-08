#include "StdAfx.h"
#include "SoundManager.hpp"
#include "SimpleHelpers.hpp"

SoundManager::SoundManager(void)
	: m_pCurrentBgm(NULL)
{
}

SoundManager::~SoundManager(void)
{
}

void SoundManager::Dispose()
{
	StopBgm();
}

bool SoundManager::OnPowerInit(Engine::Sound::IManager* mgr)
{
	m_pManager = mgr;
	m_pManager->SetPluginDirectory( L"Plugin/Sound" );
	RegistLua();
	return true;
}


void SoundManager::LoadSe(const char* path, const char* name)
{
	const int LENGTH = 256;
	wchar_t wpath[LENGTH];
	SimpleHelpers::CharToWChar(wpath, path, LENGTH);

	Engine::File::IFile* pFile = GetCore()->GetFileManager()->OpenSyncFile( wpath );
	assert(pFile != NULL);

	Se* se = m_pManager->CreateStaticSound(wpath,
																				pFile->GetData(),
																				pFile->GetSize(),
																				MAX_SE_LAYER,
																				false);
	SAFE_RELEASE( pFile );

	// すでに同名のSeが存在する場合、前のファイルを消去する
	SeItr itr = m_seMap.find(name);
	if(itr != m_seMap.end())
	{
		SAFE_RELEASE(m_seMap[name]);
		m_seMap.erase(itr);
	}

	m_seMap.insert(SePair(name, se));
}

void SoundManager::PlaySe(const char* name)
{
	assert(m_seMap.find(name) != m_seMap.end());
	m_seMap[name]->Play(0);
}

void SoundManager::SetSeVol(const char* name, float vol)
{
	assert(m_seMap.find(name) != m_seMap.end());
	m_seMap[name]->SetVolume(-1, vol);
}

void SoundManager::PlayBgm(const char* path)
{
	wchar_t fname[MAX_PATH] = L"";
	SimpleHelpers::CharToWChar(fname, path, MAX_PATH);

	// 絶対パスからの読み込みをtrueにしてファイルを開く
	Engine::File::IFile* pFile = GetCore()->GetFileManager()->OpenSyncFile( fname, true );
	if ( pFile != NULL )
	{
		// 既にあるなら解放しておく
		SAFE_RELEASE( m_pCurrentBgm );

		// サウンドの生成
		m_pCurrentBgm = m_pManager->CreateStreamSound(
							pFile,				// 直接ファイル指定
							L"OggVorbis" );		// ファイルのデコードに利用するプラグイン名

		// 使い終わったファイルの削除
		SAFE_RELEASE( pFile );

		m_pCurrentBgm->Play(-1);
	}
}

void SoundManager::StopBgm()
{
	if(m_pCurrentBgm != NULL)
	{
		m_pCurrentBgm->Stop();
		SAFE_RELEASE( m_pCurrentBgm );
	}
}

void SoundManager::SetBgmVol(float vol)
{
	m_pCurrentBgm->SetVolume(vol);
}

	
void SoundManager::Update()
{
}


void SoundManager::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<SoundManager>("SoundManager")
		.def("LoadSe", &LoadSe)
		.def("PlaySe", &PlaySe)
		.def("SetSeVol", &SetSeVol)

		.def("PlayBgm", &PlayBgm)
		.def("StopBgm", &StopBgm)
		.def("SetBgmVol", &SetBgmVol)
		.scope[
			luabind::def("GetInst", &GetInst)
		]
	];
}

