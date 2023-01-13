--[[
    Reference: 
    [1] https://pandoc.org/lua-filters.html
    [2] http://www.lua.org/manual/5.4/
]]

local logging = require('logging')

local new_path
local path_prefix

local function Meta(meta)
    logging.temp('Meta',meta)
    local meta_path = meta['path']
    local meta_title = meta['title']
    if (meta_path == nil or meta_title == nil) then
        logging.temp('Meta','no meta data found, ignored.')
        return
    end    
    new_path = pandoc.utils.stringify(meta_path)
    path_prefix = pandoc.utils.stringify(meta_title) .. '/'
end

local function Image(image)
    if (new_path == nil or path_prefix == nil) then
        return
    end
    local length = pandoc.text.len(path_prefix)
    local prefix = pandoc.text.sub(image.src,1,length)
    local postfix = pandoc.text.sub(image.src,length+1)
    if (prefix == path_prefix) then
        image.src = new_path .. postfix
    end
    return image
end

local function RawBlock (raw)
    if raw.format:match('html') then
        local res = pandoc.read(raw.text,'html')
        -- https://pandoc.org/lua-filters.html#type-blocks
        if ( #res.blocks == 1 ) then
            -- convert Plain to Para
            return pandoc.Para(res.blocks[1].content)
        end
    end
end

-- function Pandoc(pandoc)
--     logging.temp('Pandoc',pandoc)
-- end

-- return in global scope (can be loaded via `require`)
return {
    { RawBlock = RawBlock },
    { Meta = Meta },
    { Image = Image },
    -- { Pandoc = Pandoc }
}