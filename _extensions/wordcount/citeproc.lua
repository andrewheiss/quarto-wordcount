-- Lua filter that behaves like `--citeproc`
function Pandoc (doc)
  return pandoc.utils.citeproc(doc)
end
