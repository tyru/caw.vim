local languages = {
  cs = 'c_sharp',
  javascriptreact = 'jsx',
  sh = 'bash',
  typescriptreact = 'tsx',
}

local M = {}

function M.has_syntax(lnum, col)
  local bufnr = vim.api.nvim_get_current_buf()
  -- vim.treesitter.highlighter.hl_map was removed with Neovim 0.8.0 release.
  -- see: https://github.com/neovim/neovim/pull/19931
  if vim.fn.has("nvim-0.5.0") == 1 and vim.fn.has("nvim-0.8.0") == 0 then
    local col = col - 1
    local filetype = vim.api.nvim_buf_get_option(bufnr, "ft")
    local lang = languages[filetype] or filetype
    if not require("vim.treesitter.language").require_language(lang, nil, true) then
      return false
    end
    local query = require("vim.treesitter.query").get_query(lang, "highlights")
    local tstree = vim.treesitter.get_parser(bufnr, lang):parse()[1]
    local tsnode = tstree:root()

    for _, match in query:iter_matches(tsnode, bufnr, lnum - 1, lnum) do
      for id, node in pairs(match) do
        local _, start_col, _, end_col = node:range()
        local name = query.captures[id]
        local highlight = vim.treesitter.highlighter.hl_map[name]

        if col >= start_col and col < end_col and string.match(highlight, "Comment") then
          return true
        end
      end
    end
  elseif vim.fn.has("nvim-0.8.0") == 1 then
    -- vim.treesitter.get_captures_at_pos using 0-based coordinate
    local captures = vim.treesitter.get_captures_at_pos(bufnr, lnum - 1, col - 1)
    for _, capture in ipairs(captures) do
      if capture.capture == "comment" then
        return true
      end
    end
  end

  return false
end

return M
