
if(SERVER)then return end

local t = {
 font = "Default",--Base Font
 size = 24,--How Big it is
 weight = 700,--How Thick the font is
 blursize = 0,
 scanlines = 0,
 antialias = true,--Enable AA
 underline = false,--Add Underlines?
 italic = false,--Italics?
 strikeout = false,--Add Line down middle?
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false--Outline it?
}

surface.CreateFont("BigBoldFont",t )

local t = {
 font = "Default",--Base Font
 size = 20,--How Big it is
 weight = 400,--How Thick the font is
 blursize = 0,
 scanlines = 0,
 antialias = true,--Enable AA
 underline = true,--Add Underlines?
 italic = false,--Italics?
 strikeout = false,--Add Line down middle?
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false--Outline it?
}

surface.CreateFont("UnderlinedText",t )
