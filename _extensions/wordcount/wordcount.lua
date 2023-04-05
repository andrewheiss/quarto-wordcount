--[[
  Counts words in a document

  Images and tables are ignored; words in text body do not include referece section

  This filter is an adapted mixture of
  https://github.com/pandoc/lua-filters/blob/master/wordcount/wordcount.lua
  and
  https://github.com/pandoc/lua-filters/blob/master/section-refs/section-refs.lua
  ]]

local body_words = 0
local ref_words = 0

function is_table (blk)
   return (blk.t == "Table")
end

function is_image (blk)
   return (blk.t == "Image")
end

function remove_all_tables_images (blks)
   local out = {}
   for _, b in pairs(blks) do
      if not (is_table(b) or is_image(b)) then
	      table.insert(out, b)
      end
   end
   return out
end

function is_ref_div (blk)
   return (blk.t == "Div" and blk.identifier == "refs")
end

function is_ref_header (blk)
  local metadata_title = refs_title
  if refs_title then
    metadata_title = metadata_title[1].c:lower():gsub(" ", "-")
  end
  return (blk.t == "Header" and (blk.identifier == "references" or blk.identifier == metadata_title))
end

function get_all_refs (blks)
  local out = {}
   for _, b in pairs(blks) do
      if is_ref_div(b) then
	      table.insert(out, b)
      end
   end
   return out
end

function remove_all_refs (blks)
   local out = {}
   for _, b in pairs(blks) do
      if not (is_ref_div(b) or is_ref_header(b)) then
	      table.insert(out, b)
      end
   end
   return out
end

body_count = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
      body_words = body_words + 1
    end
  end,

  Code = function(el)
    _,n = el.text:gsub("%S+","")
    body_words = body_words + n
  end,

  CodeBlock = function(el)
    _,n = el.text:gsub("%S+","")
    body_words = body_words + n
  end
}

ref_count = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
      ref_words = ref_words + 1
    end
  end
}

function Pandoc(el)
  if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
    io.stderr:write("WARNING: pandoc >= 2.1 required for wordcount filter\n")
    return el
  end

  local untabled = remove_all_tables_images(el.blocks)

  refs_title = el.meta["reference-section-title"]
  local unreffed = remove_all_refs(untabled)
  pandoc.walk_block(pandoc.Div(unreffed), body_count)
  local body_words_out = body_words .. " words in text body"
  
  local refs = get_all_refs(untabled)
  pandoc.walk_block(pandoc.Div(refs), ref_count)
  local ref_words_out = ref_words .. " words in reference section"
  
  local total_words_out = body_words + ref_words .. " total words"
  
  local longest_out = math.max(string.len(body_words_out), 
                               string.len(ref_words_out), 
                               string.len(total_words_out))
  
  print(total_words_out)
  print(string.rep("-", longest_out))
  print(body_words_out)
  print(ref_words_out)
  print()
  
  return el
end
