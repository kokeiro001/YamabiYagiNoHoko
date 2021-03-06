#include "StdAfx.h"
#include "GraphicsManager.hpp"

typedef Graphics::Resource::ITexture Texture;
typedef Graphics::Resource::Text::ITextData TextData;

using namespace Selene::Engine::Graphics::Simple;

// フォントを読み込む
class FontSpriteTextureLoader
	: public Engine::Graphics::Resource::IFileLoadListener
{
private:
	virtual bool OnLoad( const wchar_t* pFileName, const void*& pFileBuffer, Sint32& FileSize, void*& pUserData, void* pUserSetData )
	{
		Engine::File::IPackFile* pPackFile = static_cast<Engine::File::IPackFile*>(pUserSetData);
		if ( pPackFile->Seek( pFileName ) )
		{
			pFileBuffer	= pPackFile->GetData();
			FileSize	= pPackFile->GetSize();

			return true;
		}
		return false;
	}
	virtual void OnRelease( const void* pFileBuffer, Sint32 FileSize, void* pUserData, void* pUserSetData )
	{
	}
};

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
  // Luaから読み込んだ文字列を、Seleneで扱えるように変換する
	wchar_t wpath[ 256 ];
	SimpleHelpers::StrToWChar(wpath, path);

  // 既にテクスチャを読み込んでいた場合、削除してから読み込む(実質上書き読み込みをする)
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
    // ファイルが見つからない！
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

  // 既に登録されている場合、スキップする
	if(m_textures.find(name) != m_textures.end()) return;

	LoadTexture(path, name);
}

Texture* GraphicsManager::GetTexture(const std::string name)
{
  // 登録されてなかったら落とす
	assert(m_textures.find(name) != m_textures.end());
	return m_textures[name];
}

Point2DI GraphicsManager::GetTextureSize(const std::string name)
{
	return GetTexture(name)->GetTextureSize();
}

TextData* GraphicsManager::GetTextData(std::string font)
{
	assert(m_texts.find(font) != m_texts.end());
	return m_texts[font]; 
}

void GraphicsManager::LoadFont(const std::string fileName, const std::string fontName, const std::string registName)
{

	wchar_t wFileName[128];
	SimpleHelpers::StrToWChar(wFileName, fileName);
	FontSpriteTextureLoader Loader;

  // ファイルを開く
	File::IFile* pFile = GetCore()->GetFileManager()->OpenSyncFile( wFileName );
	File::IPackFile* pFontPack = GetCore()->GetFileManager()->CreatePackFile( pFile );

  // ファイルを読み込む際のパラメータを設定する
	Engine::Graphics::STextureLoadParameter Param;
	Param.IsFromFile				= true;
	Param.IsCompressFormat	= false;
	Param.IsMipmapEnable		= false;
	Param.SizeDivide				= 1;
	Param.ColorKey					= 0x00000000;

  // Seleneで扱える文字形式に変換する
	wchar_t wFontName[128];
	SimpleHelpers::StrToWChar(wFontName, fontName);
	if(!pFontPack->Seek( wFontName ))
	{
		MessageBox(NULL, "error", "file open error", 0);
	}

  // テキストデータを読み込む
	Graphics::Resource::Text::ITextData*	pText = 
			GetCore()->GetGraphicsManager()->CreateText(
											pFontPack->GetData(),		// ファイルデータ
											pFontPack->GetSize(),		// ファイルサイズ
											pFontPack->GetFileName(),	// ファイル名
											Param,						// テクスチャ生成用パラメーター
											&Loader,					// リソース読み込み用リスナー
											pFontPack );				// ユーザーデータ（Resource::IFileLoadListenerのpUserSetData引数）

  // リソースを破棄する
	SAFE_RELEASE( pFontPack );
	SAFE_RELEASE( pFile );
	m_texts.insert(TextMapPair(registName, pText));
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

  // 1x1のテクスチャを作成する
	rc::ITexture*			pTexture = m_pManager->CreateCpuAccessTexture( Point2DI(1, 1), false, true );
	rc::STextureLockInfo	stInfo;
	if ( pTexture->Lock( stInfo ) )
	{
  	// 真っ白にする
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
		.def("LoadFont", &LoadFont)
		.def("GetTexture", &GetTexture)
		.def("GetTextureSize", &GetTextureSize)
		.def("RemoveTexture", &RemoveTexture)
		.def("ClearTexture", &ClearTexture)
		.scope[
			luabind::def("GetInst", &GetInst)
		]
	];
}


