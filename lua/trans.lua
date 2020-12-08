local api = vim.api

local M = {}

local function translateText(line, from, to)
  local text = table.concat(line, '')
  return vim.fn.system(string.format('trans %s:%s --brief --no-autocorrect "%s"', from or '', to or '', text))
end

local function getLines()
  local open = api.nvim_buf_get_mark(0, '<')
  local close = api.nvim_buf_get_mark(0, '>')

  -- get text from visual
  local lines = api.nvim_buf_get_lines(0, open[1] - 1, close[1], true)
  local endColumn = #lines[1]
  close[2] = math.min(close[2] + 1, endColumn)
  if #lines > 1 then
    print('translation on multiple lines not implemented')
    return nil
  else
    lines[1] = string.sub(lines[1], open[2] + 1, close[2])
  end
  return lines
end

local function replace(text)
  text = text:gsub('\n', '')
  vim.fn.setreg('t', text)
  vim.cmd [[norm gv"tp]]
end

function M.translate(to, from)
  local lines = getLines()
  if not lines then
    return
  end
  local trans = translateText(lines, from, to)
  replace(trans)
end

return M
