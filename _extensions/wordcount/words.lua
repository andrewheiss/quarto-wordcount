return {
  ['words-body'] = function(args, kwargs, meta)
    return pandoc.Str("words-body")
  end,
  ['words-ref'] = function(args, kwargs, meta)
    return pandoc.Str(meta.wordcount_ref_words)
  end,
  ['words-append'] = function(args, kwargs, meta)
    return pandoc. Str(meta.wordcount_appendix_words)
  end,
  ['words-total'] = function(args, kwargs, meta)
    return pandoc. Str(meta.wordcount_total_words)
  end
}
