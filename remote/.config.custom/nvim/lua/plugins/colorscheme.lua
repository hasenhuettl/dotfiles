return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    -- Color scheme
    local dark_mode = os.getenv("dark_mode")
    if dark_mode == "true" then
      vim.cmd[[colorscheme catppuccin-frappe]]
      vim.opt.background = "dark"
    else
      vim.cmd[[colorscheme catppuccin-latte]]
      vim.opt.background = "light"
    end

    -- Enable transparent background while preserving fg and other attributes
    vim.cmd("highlight Normal guibg=NONE")
    vim.cmd("highlight NormalNC guibg=NONE")
    vim.cmd("highlight VertSplit guibg=NONE")
    vim.cmd("highlight StatusLine guibg=NONE")
    vim.cmd("highlight StatusLineNC guibg=NONE")
    vim.cmd("highlight TabLine guibg=NONE")

    -- -- Make diagnostic underlines squiggly and colorful!
    -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "Red" })
    -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { undercurl = true, sp = "Orange" })
    -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { undercurl = true, sp = "LightBlue" })
    -- vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { undercurl = true, sp = "LightGrey" })
  end,
}

-- Alternative: tokyonight
--return {
--  "folke/tokyonight.nvim",
--  lazy = false,
--  priority = 1000,
--  --opts = {},
--  opts = {
--    transparent_background = true,
--  },
--  config = function()
--    vim.cmd[[colorscheme tokyonight-day]]
--  end
--}
