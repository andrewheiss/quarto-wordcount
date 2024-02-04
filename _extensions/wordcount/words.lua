
return {
  ['words-body'] = function(args, kwargs, meta)
    return pandoc.Str(meta.wordcount_body_words)
  end,
  ['words-ref'] = function(args, kwargs, meta)
    return pandoc.Str(meta.wordcount_ref_words)
  end,
  ['words-append'] = function(args, kwargs, meta)
    return pandoc.Str(meta.wordcount_appendix_words)
  end,
  ['words-note'] = function(args, kwargs, meta)
    return pandoc.Str(meta.wordcount_note_words)
  end,
  ['words-total'] = function(args, kwargs, meta)
    return pandoc.Str(meta.wordcount_total_words)
  end,
  ['words-sum'] = function(args, kwargs, meta)
    local nargs = #args
    local count = 0
    if nargs == 0  then
      return pandoc.Str(0)
    end
    print(args)
    local arg = args[1][1].text
    print(arg)
    if arg:match("body") then
      count = count + meta.wordcount_body_words
    end
    if arg:match("ref") then
      count = count + meta.wordcount_ref_words
    end
    if arg:match("append") then
      count = count + meta.wordcount_appendix_words
    end
    if arg:match("note") then
      count = count + meta.wordcount_note_words
    end
    return pandoc.Str(count - nargs)
  end
}
