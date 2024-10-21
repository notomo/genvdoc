local Option = {}

Option.default = {
  source = {
    patterns = { "lua/**/*.lua" },
  },
  output_dir = "./doc/",
  chapters = {},
}

function Option.new(raw_opts)
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", Option.default, raw_opts)
end

return Option
