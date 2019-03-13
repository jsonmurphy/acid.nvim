-- luacheck: globals vim
local forms = {}

forms.get_form_boundaries = function()
  local to_filter, from_filter
  local curpos = vim.api.nvim_call_function("getcurpos", {})
  local last_parens = vim.api.nvim_call_function("strcharpart", {
      vim.api.nvim_call_function("getline", {curpos[2]}),
      curpos[3] - 1, 1
  })

  if last_parens == ")" then
    to_filter = "nc"
    from_filter = "nb"
  else
    to_filter = "n"
    from_filter = "nbc"
  end

  local to = vim.api.nvim_call_function("searchpairpos", {"(", "", ")", to_filter})
  local from = vim.api.nvim_call_function("searchpairpos", {"(", "", ")", from_filter})

  -- FIXME solve boundaries for if cursor at `)`
  to[2] = to[2] + 1

  return {
    from = from,
    to = to
  }
end

forms.extract = function(bufnr)
  local coordinates = forms.get_form_boundaries(bufnr)

  local lines = vim.api.nvim_buf_get_lines(bufnr, coordinates.from[1] - 1, coordinates.to[1], 0)

  if coordinates.from[2] ~= 0 then
    lines[1] = string.sub(lines[1], coordinates.from[2])
  end

  if coordinates.to[2] ~= 0 then
    if coordinates.from[1] == coordinates.to[1] then
      lines[#lines] = string.sub(lines[#lines], 1, coordinates.to[2] - coordinates.from[2])
    else
      lines[#lines] = string.sub(lines[#lines], 1, coordinates.to[2])
    end
  end

  return lines, coordinates
end

forms.form_under_cursor = function()
  local cb = vim.api.nvim_get_current_buf()

  local form = forms.extract(cb)
  return form
end


return forms