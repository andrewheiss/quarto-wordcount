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
local appendix_words = 0

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
      if not (is_ref_div(b)) then
	      table.insert(out, b)
      end
   end
   return out
end

-- Check if the block is an appendix div
function is_appendix_div (blk)
   return (blk.t == "Div" and blk.identifier == "appendix-count")
end

-- Get all appendix divs
function get_all_appendix (blks)
  local out = {}
   for _, b in pairs(blks) do
      if is_appendix_div(b) then
          table.insert(out, b)
      end
   end
   return out
end

-- Remove all appendix divs
function remove_all_appendix (blks)
   local out = {}
   for _, b in pairs(blks) do
      if not is_appendix_div(b) then
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

-- Count words in the appendix
appendix_count = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
      appendix_words = appendix_words + 1
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
  
  -- Remove appendix divs from the blocks
  local unappended = remove_all_appendix(unreffed)
  -- Walk through the unappended blocks and count the words
  pandoc.walk_block(pandoc.Div(unappended), body_count)
  
  local body_words_out = body_words .. " words in text body"
  
  local refs = get_all_refs(untabled)
  pandoc.walk_block(pandoc.Div(refs), ref_count)
  local ref_words_out = ref_words .. " words in reference section"
  
  -- Get all appendix divs
  local appendix = get_all_appendix(unreffed)
  -- Walk through the appendix divs and count the words
  pandoc.walk_block(pandoc.Div(appendix), appendix_count)
  -- Print out the count of words in the appendix
  local appendix_words_out = appendix_words .. " words in appendix section"
  
  local total_words_out = ""
  if appendix_words > 0 then
    total_words_out = body_words + ref_words .. " in the main text + references, with " .. appendix_words .. " in the appendix"
  else
    total_words_out = body_words + ref_words + appendix_words .. " total words"
  end
  
  local longest_out = math.max(string.len(body_words_out), 
                               string.len(ref_words_out), 
                               string.len(total_words_out))
  
  print(total_words_out)
  print(string.rep("-", longest_out))
  print(body_words_out)
  print(ref_words_out)
  
  if appendix_words > 0 then
    print(appendix_words_out)
  end
  
  print()
  
  return el
end
