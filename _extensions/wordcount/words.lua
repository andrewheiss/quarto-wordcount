
as_str = function(meta_value, name)
  if (meta_value == nil) then
    print("cannot find " .. name .. " in meta data")
    return pandoc.Null()
  end
  return pandoc.Str(meta_value) 
end

as_num = function(meta_value, name)
  if (meta_value == nil) then
    print("cannot find " .. name .. " in meta data")
    return 0
  end
  return meta_value
end

return {
  ['words-body'] = function(args, kwargs, meta)
    return as_str(meta.wordcount_body_words, "wordcount_body_words")
  end,
  ['words-ref'] = function(args, kwargs, meta)
    return as_str(meta.wordcount_ref_words, "wordcount_ref_words")
  end,
  ['words-append'] = function(args, kwargs, meta)
    return as_str(meta.wordcount_appendix_words, "wordcount_appendix_words")
  end,
  ['words-note'] = function(args, kwargs, meta)
    return as_str(meta.wordcount_note_words, "wordcount_note_words")
  end,
  ['words-total'] = function(args, kwargs, meta)
    return as_str(meta.wordcount_total_words, "wordcount_total_words")
  end,
  ['words-sum'] = function(args, kwargs, meta)
    local nargs = #args
    local count = 0
    if nargs == 0  then
      return pandoc.Str(0)
    end
    --print(args)
    local arg = args[1]
    --print(arg)
    if arg:match("body") then
      count = count + as_num(meta.wordcount_body_words, "wordcount_total_words")
    end
    if arg:match("ref") then
      count = count + as_num(meta.wordcount_ref_words, "wordcount_ref_words")
    end
    if arg:match("append") then
      count = count + as_num(meta.wordcount_appendix_words, "wordcount_appendix_words")
    end
    if arg:match("note") then
      count = count + as_num(meta.wordcount_note_words, "wordcount_note_words")
    end
    return pandoc.Str(count - nargs)
  end
}
