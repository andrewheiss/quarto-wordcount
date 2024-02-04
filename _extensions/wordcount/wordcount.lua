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
local note_words = 0
local appendix_words = 0
local total_words = 0

function set_meta(m)
  m.wordcount_body_words = body_words
  m.wordcount_ref_words = ref_words
  m.wordcount_appendix_words = appendix_words
  m.wordcount_note_words = note_words
  m.wordcount_total_words = body_words + ref_words + appendix_words + note_words
  return m
end

function count_words(blks)
  local count = 0
  pandoc.walk_block(pandoc.Div(blks), {
    Str = function(el)
      if is_word(el.text) then
        count = count + 1
      end
    end
  })
  return count
end

function is_no_count_div (blk)
  if (blk and blk.t=="Div" and blk.classes and #blk.classes > 0) then
    for _, class in pairs(blk.classes) do
      if class=="no-count" then
        return true
      end
    end
  end
  return false
end

function is_table (blk)
   return (blk.t == "Table")
end

function is_image (blk)
   return (blk.t == "Image" or blk.t == "Figure")
end

function is_word (text)
  return text:match("%P") and not (text:match("“") or text:match("”"))
end

function remove_all_tables_images (blks)
  return pandoc.walk_block(pandoc.Div(blks),
    {
      Table = function(el)
        return {}
      end,
      Image = function(el)
        return {}
      end,
      Figure = function(el)
        return {}
      end,
      Div = function(el)
        if is_no_count_div(el) then
          return {}
        end
        return el
      end
    }).content
end

function is_ref_div (blk)
   return (blk.t == "Div" and blk.identifier == "refs")
end

function get_all_notes (blks)
  -- Get all notes
  local all_notes = {}
  -- try and get notes
  pandoc.walk_block(pandoc.Div(blks),
    {
      Note = function(el)
        table.insert(all_notes, el)
      end
    })
  return all_notes
end

function remove_all_notes (blks)
  return pandoc.walk_block(
    pandoc.Div(blks),
    {
      Note = function(el)
        return {}
      end
    }
  ).content
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
    if is_word(el.text) then
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
    if is_word(el.text) then
      ref_words = ref_words + 1
    end
  end
}

-- Count words in the appendix
appendix_count = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if is_word(el.text) then
      appendix_words = appendix_words + 1
    end
  end
}

note_count = {
  Str = function(el)
    if is_word(el.text) then
      note_words = note_words + 1
    end
  end
}



function Pandoc(el)
  if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
    io.stderr:write("WARNING: pandoc >= 2.1 required for wordcount filter\n")
    return el
  end

  -- Get all notes
  local all_notes = get_all_notes(el.blocks)
  -- count words in notes
  pandoc.walk_block(pandoc.Div(all_notes), note_count)
  local note_words_out = note_words .. " words in notes section"

  -- Remove Tables, Images, and {.no-count} contents
  local untabled = remove_all_tables_images(el.blocks)
  -- Next remove notes
  local unnote = remove_all_notes(untabled)

  refs_title = el.meta["reference-section-title"]
  local unreffed = remove_all_refs(unnote)

  -- Remove appendix divs from the blocks
  local unappended = remove_all_appendix(unreffed)

  -- Walk through the unappended blocks and count the words
  pandoc.walk_block(pandoc.Div(unappended), body_count)
  -- notes and double counted by body
  --body_words = body_words - note_words
  local body_words_out = body_words .. " words in text body"
  
  local refs = get_all_refs(unnote)
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

  if note_words > 0 then
    print(note_words_out)
  end

  if appendix_words > 0 then
    print(appendix_words_out)
  end

  print()
  -- modify meta data for words.lua
  el.meta = set_meta(el.meta)

  return el
end
