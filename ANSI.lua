-- should be used with something that supports ANSI (unlike print/io.write)
-- i use os.execute('echo ...')

local ANSI = {}

local esc = '033' -- '033' or 'e', for sh or bash, respectively (lua seems to like sh over bash)

ANSI.codes = {
  --formatting
  ['reset']='0',
  ['bold']='1',
  ['dim']='2',
  ['underline']='4',
  ['blink']='5',
  ['invert']='7',
  ['hide']='8',
  ['unbold']='21',
  ['undim']='22',
  ['ununderline']='24',
  ['unblink']='25',
  ['uninvert']='27',
  ['unhide']='28',
  --colors
  ['fgdefault']='39',
  ['fgblack']='30',
  ['fgred']='31',
  ['fggreen']='32',
  ['fgyellow']='33',
  ['fgblue']='34',
  ['fgmagenta']='35',
  ['fgcyan']='36',
  ['fglightgray']='37',
  ['fgdarkgray']='90',
  ['fglightred']='91',
  ['fglightgreen']='92',
  ['fglightyellow']='93',
  ['fglightblue']='94',
  ['fglightmagenta']='95',
  ['fglightcyan']='96',
  ['fgwhite']='97',
  ['bgdefault']='49',
  ['bgblack']='40',
  ['bgred']='41',
  ['bggreen']='42',
  ['bgyellow']='43',
  ['bgblue']='44',
  ['bgmagenta']='45',
  ['bgcyan']='46',
  ['bglightgray']='47',
  ['bgdarkgray']='100',
  ['bglightred']='101',
  ['bglightgreen']='102',
  ['bglightyellow']='103',
  ['bglightblue']='104',
  ['bglightmagenta']='105',
  ['bglightcyan']='106',
  ['bgwhite']='107',
  --cursor movement
  ['term']={ 
    ['cup']='<N>A',
    ['cdown']='<N>B',
    ['cforward']='<N>C',
    ['cbackward']='<N>D',
    ['setpos']='<N>;<N>H',
    ['setpos2']='<N>;<N>f',
    ['clear']='2J',
    ['erase']='K',
    -- save, restore cursor pos
    -- only for xterm, nxterm
    ['save']='s',
    ['restore']='u'
  }
}

-- used for color/formatting codes
function ANSI.code(...) -- assembles multiple color/formatting codes into a single sequence
  local sequence = '\\'..esc..'['
  for i,v in ipairs({...}) do
    assert(type(v)=='string', 'Bad argument #'..tostring(i)..': expected string, got '..type(v))
    assert(ANSI.codes[v], 'Invalid or unsupported ANSI escape code ('..v..')')
    sequence = sequence..(i == 1 and '' or ';')..ANSI.codes[v]
  end
  return sequence..'m'
end

-- used for other codes
function ANSI.term(code, ...) -- can only return one codeper sequence
  assert(type(code)=='string', 'Bad argument #1: expected string, got '..type(code))
  assert(ANSI.codes.term[code], 'Invalid or unsupported ANSI escape code ('..code..')')
  local sequence = '\\'..esc..'['..ANSI.codes.term[code]
  for i,v in ipairs({...}) do
    assert(type(v)=='string', 'Bad argument #'..tostring(i+1)..': expected string, got '..type(v))
    sequence = sequence:gsub('<N>', v, 1)
  end
  return sequence
end

--[[ testing code; makes sure parsers work right
for code, def in pairs(ANSI.codes) do
  if code~='term' then
    local o=ANSI.code(code)
    print(o)
  else
    for scode, def in pairs(def) do
      local o=ANSI.term(scode, '1', '1')
      print(o)
    end
  end
end
--]]

return ANSI
