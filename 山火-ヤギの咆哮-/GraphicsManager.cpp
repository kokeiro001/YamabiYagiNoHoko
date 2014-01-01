#include "StdAfx.h"
#include "GraphicsManager.hpp"

typedef Graphics::Resource::ITexture Texture;
using namespace Selene::Engine::Graphics::Simple;

GraphicsManager::GraphicsManager(void)
{
}

GraphicsManager::~GraphicsManager(void)
{
}

bool GraphicsManager::OnPowerInit(Graphics::IManager* mgr)
{
	m_pManager = mgr;
	m_pSprite = m_pManager->CreateSpriteRenderer();

	CreateSimpleTextures();
	RegistLua();
	return true;
}

void GraphicsManager::Dispose()
{
	ClearTexture();
}


void GraphicsManager::LoadTexture(const std::string path, const std::string name)
{
	wchar_t wpath[ 256 ];
	SimpleHelpers::StrToWChar(wpath, path);


	TextureMapItr itr = m_textures.find(name);
	if(itr != m_textures.end())
	{
		itr->second->Release();
		m_textures.erase(itr);
	}

	Texture* pTex;

	Engine::File::IFile* pFile = GetCore()->GetFileManager()->OpenSyncFile( wpath );
	if(!pFile)
	{
		std::stringstream msg;
		msg << "FileNotFound.." << path << "\0" <<std::endl;
		char err[128];
		strcpy(err, msg.str().c_str());
		throw err;
	}
	// テクスチャ作成で利用するパラメーター
	Engine::Graphics::STextureLoadParameter Parameter = {
		false,							// ファイルからそのまま読み込むかどうか（trueなら他のフラグを全部無視）
		true,							// 圧縮テクスチャの有無
		true,							// ミップマップの有無
		1,								// 元のサイズに対して除算する数（2なら256x256を内部的に128x128で生成）
		ColorF(0.0f,0.0f,0.0f,0.0f),	// カラーキーを利用しない場合は(0,0,0,0)
	};

	// ファイルからテクスチャを生成する
	Engine::Graphics::Resource::ITexture* pTexture = GetCore()->GetGraphicsManager()->CreateTexture(
		pFile->GetData(),		// データのポインタ
		pFile->GetSize(),		// データのサイズ
		pFile->GetFileName(),	// データの名称（内部で同一名称のファイルを使いまわすようにしています）
		Parameter );			// 作成時のパラメーター

	SAFE_RELEASE( pFile );
	pTex = pTexture;

	m_textures.insert(TextureMapPair(name, pTex));
}
void GraphicsManager::LoadTexture2(const std::string path, const std::string name)
{
	// 上書きなしのロード
	if(m_textures.find(path) != m_textures.end()) return;

	LoadTexture(path, name);

	//wchar_t wpath[ 256 ];
	//SimpleHelpers::CharToWChar(wpath, path, 256);
	//Texture* pTex = SeleneHelper::LoadTexture(wpath);
	//m_textures.insert(Pair(name, pTex));
}

Texture* GraphicsManager::GetTexture(const std::string name)
{
	assert(m_textures.find(name) != m_textures.end());
	return m_textures[name];
}

ITextRenderer* GraphicsManager::GetTextRenderer(std::string font, int size)
{
	// フォントがあるか。無ければ追加。
	if(m_textRenderers.find(font) == m_textRenderers.end())
	{
		m_textRenderers.insert(std::make_pair(font,  std::map<int, Selene::Engine::Graphics::Simple::ITextRenderer*>()));
	}

	// 対象サイズのがあるか。無ければ追加
	if(m_textRenderers[font].find(size) == m_textRenderers[font].end())
	{
		wchar_t* tmp = NULL;
		mbstowcs(tmp, font.c_str(), font.size());
		m_textRenderers[font].insert(std::make_pair(
			size, 
			m_pManager->CreateTextRenderer( tmp, size, false, false )));
	}

	return m_textRenderers[font][size];
}

void GraphicsManager::RemoveTexture(const std::string name)
{
	assert(m_textures.find(name) != m_textures.end());
	m_textures.erase(name);
}

void GraphicsManager::ClearTexture()
{
	m_textures.clear();
}

void GraphicsManager::CreateSimpleTextures()
{
	namespace rc = Engine::Graphics::Resource;

	// 真っ白にする
	rc::ITexture*			pTexture = m_pManager->CreateCpuAccessTexture( Point2DI(1, 1), false, true );
	rc::STextureLockInfo	stInfo;
	if ( pTexture->Lock( stInfo ) == true )
	{
		memset( stInfo.pPixels, 0xFF, stInfo.Pitch * stInfo.Size.y );
		pTexture->Unlock();
		m_textures.insert(TextureMapPair("whitePix", pTexture));
	}
	m_pManager->Release();
}

void GraphicsManager::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<GraphicsManager>("GraphicsManager")
		.def("LoadTexture", &LoadTexture)
		.def("LoadTexture2", &LoadTexture2)
		.def("GetTexture", &GetTexture)
		.def("RemoveTexture", &RemoveTexture)
		.def("ClearTexture", &ClearTexture)
		.scope[
			luabind::def("GetInst", &GetInst)
		]
	];
}


