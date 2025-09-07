--[[
    Reference:
    [1] https://pandoc.org/lua-filters.html
    [2] http://www.lua.org/manual/5.4/
]]

local logging = require('logging')

local new_path
local path_prefix

local note_icon =
'<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>'
local tip_icon =
'<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.084-.1-.173-.205-.268-.32C3.201 7.75 2.5 6.766 2.5 5.25 2.5 2.31 4.863 0 8 0s5.5 2.31 5.5 5.25c0 1.516-.701 2.5-1.328 3.259-.095.115-.184.22-.268.319-.207.245-.383.453-.541.681-.208.3-.33.565-.37.847a.751.751 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5ZM6 15.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75Z"></path></svg>'
local important_icon =
'<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v9.5A1.75 1.75 0 0 1 14.25 13H8.06l-2.573 2.573A1.458 1.458 0 0 1 3 14.543V13H1.75A1.75 1.75 0 0 1 0 11.25Zm1.75-.25a.25.25 0 0 0-.25.25v9.5c0 .138.112.25.25.25h2a.75.75 0 0 1 .75.75v2.19l2.72-2.72a.749.749 0 0 1 .53-.22h6.5a.25.25 0 0 0 .25-.25v-9.5a.25.25 0 0 0-.25-.25Zm7 2.25v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 9a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"></path></svg>'
local warning_icon =
'<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"></path></svg>'
local caution_icon =
'<svg class="octicon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true"><path d="M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6a.749.749 0 0 1-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5ZM8 4a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"></path></svg>'

local function get_title_element(element)
    if #element.content < 1 then
        return nil
    end
    local title_element = element.content[1]
    if title_element.attr == nil then
        return nil
    end
    local classes = title_element.attr['classes']
    if (classes == nil or #classes == 0) then
        return nil
    end
    if not classes:find('title') then
        return nil
    end
    return title_element
end

local function get_alert_type(div)
    local classes = div.attr['classes']
    local curr_alert_type = nil
    local curr_icon = nil
    if (classes == nil or #classes == 0) then
        return curr_alert_type, curr_icon
    end
    if classes:find("note") then
        curr_alert_type = 'note'
        curr_icon = note_icon
    elseif classes:find("tip") then
        curr_alert_type = 'tip'
        curr_icon = tip_icon
    elseif classes:find("caution") then
        curr_alert_type = 'caution'
        curr_icon = caution_icon
    elseif classes:find("warning") then
        curr_alert_type = 'warning'
        curr_icon = warning_icon
    elseif classes:find("important") then
        curr_alert_type = 'important'
        curr_icon = important_icon
    end
    return curr_alert_type, curr_icon
end

local function capitalize_first(str)
    return (str:gsub("^%l", string.upper))
end

local function Div(div)
    -- check class list of <div> element
    local curr_alert_type, curr_icon = get_alert_type(div)
    -- check title element
    local title_element = get_title_element(div)
    if (curr_alert_type == nil or curr_icon == nil or title_element == nil) then
        return
    end
    -- override markdown-alert and markdown-alert-* class
    div.attr['classes'] = { 'markdown-alert', 'markdown-alert-' .. curr_alert_type }
    -- construct new title element
    div.content[1] = pandoc.Div({ pandoc.RawInline('html', curr_icon), pandoc.Strong(capitalize_first(curr_alert_type)) }, {
        class = 'markdown-alert-title'
    })
    -- logging.temp('Div',div)
    return div
end

local function Meta(meta)
    -- logging.temp('Meta',meta)
    local meta_path = meta['path']
    local meta_title = meta['title']
    if (meta_path == nil or meta_title == nil) then
        logging.temp('Meta', 'no meta data found, ignored.')
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
    local prefix = pandoc.text.sub(image.src, 1, length)
    local postfix = pandoc.text.sub(image.src, length + 1)
    if (prefix == path_prefix) then
        image.src = new_path .. postfix
    end
    -- delete image caption info and title (just a hack)
    image.caption = {}
    image.title = ''
    return image
end

local function RawBlock(raw)
    if raw.format:match('html') then
        local res = pandoc.read(raw.text, 'html')
        -- https://pandoc.org/lua-filters.html#type-blocks
        if (#res.blocks == 1) then
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
    { Div = Div },
    -- { Pandoc = Pandoc }
}
