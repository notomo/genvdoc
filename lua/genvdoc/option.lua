local Option = {}

Option.default = {
  sources = {
    { name = "lua", pattern = "lua/**/*.lua" },
  },
  output_dir = "./doc/",
  chapters = {},
}

function Option.new(raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", Option.default, raw_opts)
end

return Option
