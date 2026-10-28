-- lua/plugins/copilot.lua
return {
  "github/copilot.vim",
  -- event = "InsertEnter",
  enabled = vim.env.NVIM_COPILOT == "true",
  init = function()
    if vim.env.COPILOT_ENTERPRISE_URL then
      vim.g.copilot_enterprise_url = vim.env.COPILOT_ENTERPRISE_URL
      vim.g.copilot_auth_provider_url = vim.env.COPILOT_ENTERPRISE_URL
    end
  end,
  config = function()
    vim.g.copilot_no_tab_map = true -- use CTRL + J to accept suggestions
    vim.cmd("Copilot disable")
  end,
}
