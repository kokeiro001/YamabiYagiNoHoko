#include "StdAfx.h"

#include "Color.h"
#include "SpriteNode.hpp"
#include "boost\range\algorithm.hpp"
#include "GraphicsManager.hpp"
#include "boost\foreach.hpp"

Sprite::Sprite()
	: m_mode(SPR_NONE)
	, m_x(0.0f), m_y(0.0f), m_z(0.0f)
	, m_alpha(1.0f)
	, m_width(0.0f), m_height(0.0f), m_drawWidth(0.0f), m_drawHeight(0.0f)
	, m_centerX(0.0f), m_centerY(0.0f)
	, m_rot(0.0f), m_rotOffcetX(0.0f), m_rotOffcetY(0.0f)
	, m_pTexBuf(NULL)
	, m_divType(TEX_DIVTYPE_NONE)
	, m_useTextRenderer(true)
	, m_pTextRdr(NULL)
	, m_textColor(BLACK)
	, m_posType(DRAWPOS_RELATIVE)
{
}
Sprite::~Sprite()
{
	RemoveFromParent();
}

void Sprite::AddChild(boost::shared_ptr<Sprite> chr)
{
	m_children.push_back(chr);
	chr->SetParent(GetPtr());
}
void Sprite::RemoveChild(boost::shared_ptr<Sprite> chr)
{
	Itr itr = std::find(m_children.begin(), m_children.end(), chr);
	if(itr != m_children.end())
	{
		(*itr)->RemoveFromParentForce();
		m_children.erase(itr);
	}
}
void Sprite::ClearChild()
{
	Itr itr = m_children.begin();
	while(itr != m_children.end())
	{
		(*itr)->RemoveFromParent();
		itr = m_children.begin();
	}
	m_children.clear();
}
void Sprite::RemoveFromParent()
{
	if(m_pParent.lock())
	{
		m_pParent.lock()->RemoveChild(GetPtr());
		m_pParent.reset();
	}
}
void Sprite::RemoveFromParentForce()
{
	if(m_pParent.lock())
	{
		m_pParent.reset();
	}
}
boost::shared_ptr<Sprite> Sprite::GetChild(int idx)
{
	int i = 0;
	foreach(boost::shared_ptr<Sprite> chr, m_children)
	{
		if(i++ == idx) return chr;
	}
}


void Sprite::SetAlpha(float alpha)
{ 
	m_alpha = min(max(alpha, 0.0f), 1.0f); 
	switch(m_mode)
	{
	case SPR_TEXTURE:
		m_textureColor.a = alpha;
		break;
	case SPR_TEXT:
		m_textColor.a = alpha;
		break;
	}
}

void Sprite::SetTextureMode(const char* name)
{
	if(m_mode == SPR_TEXT)
	{
		SimpleHelpers::CharToWChar(m_text, "", MAX_TEXT);
	}

	m_mode = SPR_TEXTURE;
	m_isDraw = true;
	m_divType = TEX_DIVTYPE_NONE;
	m_pTexBuf = GraphicsManager::GetInst()->GetTexture(name);

	UpdateSize();
}
void Sprite::SetDivTextureMode(const char* name, int xnum, int ynum, int w, int h)
{
	if(m_mode == SPR_TEXT)
	{
		SimpleHelpers::CharToWChar(m_text, "", MAX_TEXT);
	}

	m_mode = SPR_TEXTURE;
	m_isDraw	= true;
	m_divType = TEX_DIVTYPE_SIMPLE;
	m_pTexBuf = GraphicsManager::GetInst()->GetTexture(name);

	m_divDrawTexIdx = 0;
	m_divX = xnum;
	m_divY = ynum;
	m_divW = w;
	m_divH = h;

	m_width		= w;
	m_height	= h;
	UpdateSize();
}
void Sprite::SetTextureSrc(int x, int y, int w, int h)
{
	m_divType = TEX_DIVTYPE_USER;
	m_srcX = x;
	m_srcY = y;
	m_srcW = w;
	m_srcH = h;
	UpdateSize();
}
void Sprite::SetTextureColorF(ColorF color)
{
	m_textureColor = color;
}

void Sprite::SetTextMode(const char* text)
{
	if(m_mode == SPR_TEXTURE)
	{
		m_pTexBuf = 0;
	}

	m_mode = SPR_TEXT;
	m_useTextRenderer = true;
	m_isDraw = true;
	m_fontName = Properties::GetDefFontName();
	m_fontSize = Properties::GetDefFontSize();
	m_pTextRdr = GraphicsManager::GetInst()->GetTextRenderer(m_fontName, m_fontSize);

	SetText(text);
}
void Sprite::SetTextMode2(const char* text, const char* fontName)
{
	if(m_mode == SPR_TEXTURE)
	{
		m_pTexBuf = 0;
	}

	m_mode = SPR_TEXT;
	m_useTextRenderer = false;
	m_isDraw = true;
	m_fontName = fontName;
	m_fontSize = Properties::GetDefFontSize();
	m_pTextData = GraphicsManager::GetInst()->GetText(m_fontName);

	SetText(text);
}

void Sprite::SetText(const char* text)
{
	SimpleHelpers::CharToWChar(m_text, text, MAX_TEXT);
	UpdateSize();
}
void Sprite::SetFontSize(int size)
{
	if(m_mode == SPR_TEXT)
	{
		if(m_useTextRenderer)
		{
			m_fontSize = size;
			m_pTextRdr = GraphicsManager::GetInst()->GetTextRenderer(m_fontName, m_fontSize);
		}
		else
		{
			m_fontSize = size;
		}
		UpdateSize();

	}
}
void Sprite::SetTextColorF(ColorF color)
{
	m_textColor = color;
}
void Sprite::SetTextColor1(float r, float g, float b)
{
	m_textColor = ColorF(r, g, b, m_alpha);
}
void Sprite::SetTextColor255(int r, int g, int b)
{
	m_textColor = ColorF(r / 255.0f, b / 255.0f, b / 255.0f, m_textColor.a);
}

void Sprite::UpdateSize()
{
	if(m_mode == SPR_TEXTURE)
	{
		if(m_divType == TEX_DIVTYPE_SIMPLE)
		{
			m_drawWidth = m_divW;
			m_drawHeight = m_divH;
		}
		else if(m_divType == TEX_DIVTYPE_USER)
		{
			m_drawWidth = m_srcW;
			m_drawHeight = m_srcH;
		}
		else
		{
			Point2DI texSize = m_pTexBuf->GetTextureSize();
			m_width = texSize.x;
			m_height = texSize.y;
			m_drawWidth = texSize.x;
			m_drawHeight = texSize.y;
		}
	}
	else if(m_mode == SPR_TEXT)
	{
		if(m_useTextRenderer)
		{
			Point2DI size = m_pTextRdr->GetDrawSize(m_text);
			m_width  = size.x;
			m_height = size.y;
			m_drawWidth = size.x;
			m_drawHeight = size.y;
		}
		else
		{
			Point2DI size = m_pTextData->GetDrawSize(m_text);
			m_width  = size.x;
			m_height = size.y;
			m_drawWidth = size.x;
			m_drawHeight = size.y;
		}
	}
}
Point2DI Sprite::GetOriginTexSize()
{
	return m_pTexBuf->GetTextureSize();
}

void Sprite::DrawThis(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY)
{
	float revX = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseX;
	float revY = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseY;
	if(m_mode == SPR_TEXTURE)
	{
		RectF src;
		if(m_divType == TEX_DIVTYPE_SIMPLE)
		{
			int xidx = m_divDrawTexIdx % m_divX;
			int yidx = m_divDrawTexIdx / m_divX;
			src = RectF(xidx * m_divW, yidx * m_divH, m_divW, m_divH);
		}
		else if(m_divType == TEX_DIVTYPE_USER)
		{
			src = RectF(m_srcX, m_srcY, m_srcW, m_srcH);
		}
		else
		{
			Point2DI texSize = m_pTexBuf->GetTextureSize();
			src =	RectF((float)0, (float)0, (float)texSize.x, (float)texSize.y);
		}
		pSpr->CacheReset();

		pSpr->SquareRequest(
			RectF(m_x - m_centerX + revX, m_y - m_centerY + revY, m_drawWidth, m_drawHeight),
			0,
			m_textureColor,
			src,
			m_pTexBuf,
			false,
			false,
			Engine::Graphics::State::AB_BLEND,
			m_rot,
			Point2DF(m_rotOffcetX, m_rotOffcetY));
		pSpr->CacheDraw();
	}
	else if(m_mode == SPR_TEXT)
	{
		if(m_useTextRenderer)
		{
			m_pTextRdr->CacheReset();
			m_pTextRdr->DrawRequest(Point2DI(m_x  - m_centerX + revX, m_y  - m_centerY + revY), m_textColor, m_text);
			m_pTextRdr->CacheDraw();
		}
		else
		{
			m_pTextData->DrawDirect(
				Point2DI(m_x  - m_centerX + revX, m_y  - m_centerY + revY),
				ColorF(1, 1, 1),
				m_text);
		}
	}

}

void Sprite::Draw(Engine::Graphics::Simple::ISpriteRenderer* pSpr, float baseX, float baseY, int level)
{
	if(!m_isDraw) return;

	float revX = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseX;
	float revY = m_posType == DRAWPOS_ABSOLUTE ? 0 : baseY;


	static boost::shared_ptr<Sprite> damy(new Sprite());

	if(m_children.empty())
	{
		DrawThis(pSpr, baseX, baseY);
	}
	else
	{
		m_children.push_back(damy);
		//TODO:sort
		//SortZ();
		foreach(boost::shared_ptr<Sprite> chr, m_children)
		{
			if(chr == damy)
			{
				DrawThis(pSpr, baseX, baseY);
			}
			else
			{
				chr->Draw(pSpr, m_x + revX, m_y + revY, level + 1);
			}
		}
		m_children.remove(damy);
	}
}

void Sprite::SortZ()
{
	m_children.sort([](boost::shared_ptr<Sprite> a, boost::shared_ptr<Sprite> b) -> bool { return a->GetZ() > b->GetZ(); });
	foreach(boost::shared_ptr<Sprite> chr, m_children)
	{
		chr->SortZ();
	}
}


void Sprite::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<Sprite, boost::shared_ptr<Sprite>>("Sprite")
		.def(luabind::constructor<>())
		.def("IsDraw", &IsDraw)
		.def("Show", &Show)
		.def("Hide", &Hide)

		.def("SetTextureMode", &SetTextureMode)
		.def("SetDivTextureMode", &SetDivTextureMode)
		.def("SetTextureSrc", &SetTextureSrc)
		.def("SetTextureColorF", &SetTextureColorF)

		.def("SetDrawPosAbsolute", &SetDrawPosAbsolute)
		.def("SetDrawPosRelative", &SetDrawPosRelative)

		.def("SetText", &SetText)
		.def("SetTextMode", &SetTextMode)
		.def("SetTextMode2", &SetTextMode2)
		.def("SetFontSize", &SetFontSize)
		.def("SetTextColor1", &SetTextColor1)
		.def("SetTextColorF", &SetTextColorF)
		.def("SetTextColor255", &SetTextColor255)

		.def("AddChild", &AddChild)
		.def("RemoveChild", &RemoveChild)
		.def("RemoveFromParent", &RemoveFromParent)
		.def("ClearChild", &ClearChild)
		.def("GetChild", &GetChild)
		.def("GetChildCnt", &GetChildCnt)

		.def("SetPos", (void(Sprite::*)(float, float))&Sprite::SetPos)
		.def("SetPos", (void(Sprite::*)(float, float, float))&Sprite::SetPos)
		.def("SetCenter", &SetCenter)
		.def("SortZ", &SortZ)

		.def("GetBounds", &GetBounds)

		.property("name", &GetName, &SetName)
		.property("alpha", &GetAlpha, &SetAlpha)
		.property("x", &GetX, &SetX)
		.property("y", &GetY, &SetY)
		.property("z", &GetZ, &SetZ)
		.def_readonly("width", &GetWidth)
		.def_readonly("height", &GetHeight)
		.def_readonly("originTexSize", &GetOriginTexSize)
		.property("drawWidth", &GetDrawWidth, &SetDrawWidth)
		.property("drawHeight", &GetDrawHeight, &SetDrawHeight)
		.property("cx", &GetCenterX, &SetCenterX)
		.property("cy", &GetCenterY, &SetCenterY)
		.property("rot", &GetRot, &SetRot)
		.property("rotX", &GetRotOffcetX, &SetRotOffcetX)
		.property("rotY", &GetRotOffcetY, &SetRotOffcetY)
		.property("divTexIdx", &GetDivDrawTexIdx, &SetDivDrawTexIdx)
	];
}



bool DrawSystem::OnPowerInit()
{
	m_baseSprite.reset(new Sprite());
	m_baseSprite->Show();
	RegistLua();
	return true;
}

void DrawSystem::Dispose()
{
	m_baseSprite.reset();
}

void DrawSystem::AddSprite(boost::shared_ptr<Sprite> spr)
{
	m_baseSprite->AddChild(spr);
}

void DrawSystem::RemoveSprite(boost::shared_ptr<Sprite> spr)
{
	m_baseSprite->RemoveChild(spr);
}

void DrawSystem::ClearSprite()
{
	m_baseSprite->ClearChild();
}

boost::shared_ptr<Sprite> DrawSystem::GetSprite()
{
	return boost::shared_ptr<Sprite>(new Sprite());
}

void DrawSystem::Draw()
{
	m_baseSprite->Draw(GraphicsManager::GetInst()->GetSprite(), 0, 0, 0);
}

void DrawSystem::RegistLua()
{
	luabind::module(LuaHelper::GetInst()->GetLua())
	[
		luabind::class_<DrawSystem>("DrawSystem")
		.def("GetSprite", &GetSprite)
		.def("AddSprite", &AddSprite)
		.def("RemoveSprite", &RemoveSprite)
		.def("ClearSprite", &ClearSprite)
		.scope[
			luabind::def("GetInst", &GetInst)
		]
		
	];
}



