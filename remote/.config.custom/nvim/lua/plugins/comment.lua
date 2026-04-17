return {
  'echasnovski/mini.comment',
  opts = {
    -- Options which control module behavior
    options = {
      -- Function to compute custom 'commentstring' (optional)
      custom_commentstring = nil,
      -- Whether to ignore blank lines when commenting
      ignore_blank_line = false,
      -- Whether to recognize as comment only lines without indent
      start_only = false,
      -- Whether to ensure single space pad for comment parts
      pad_comment_parts = true, -- replaces `padding = true`
    },
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Toggle comment (like `gcc` / `gbc`) on current line
      comment_line = 'gcc',       -- was toggler.line
      -- Toggle comment on visual selection or text object
      comment = 'gc',             -- was opleader.line
      -- Toggle block comment
      comment_visual = 'gc',
      -- Define 'comment' textobject (like `dgc` to delete comment)
      textobject = 'gc',
    },
    -- Hook functions to be executed at certain stage of commenting
    hooks = {
      pre = nil,   -- was pre_hook
      post = nil,  -- was post_hook
    },
  },
}
