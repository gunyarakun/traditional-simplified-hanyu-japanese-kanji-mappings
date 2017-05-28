#!/usr/bin/env ruby
# coding: utf-8

open('../sources/kanjibukuro/Variants') do |f|
  line_no = 0
  results = []
  f.each_line do |line|
    line_no += 1
    next if line[0] == '#'
    line.chomp!
    variants = line.split(' ')
    result = {
      kanji: [],
      simplified: [],
      traditional: [],
    }
    variants.each do |identicals_comma_separated|
      identicals = identicals_comma_separated.split(',')

      kanji = false
      traditional = false
      simplified = false
      character = nil

      identicals.each do |char_ref|
        set_str, code = char_ref.split('-')
        set = set_str.intern

        case set
        when :JIS78, :JIS83, :JIS90, :JIS, :'JIS+'
          kanji = true
        when :GB, :GB1, :GB2, :GB3, :GB4, :GB5, :'GB+', :GBK
          simplified = true
        when :CNS1, :CNS2, :CNS3, :CNS4, :CNS5, :CNS6, :CNS7, :BIG5
          traditional = true
        when :UCS
          character = code.to_i(16).chr(Encoding::UTF_16LE).encode(Encoding::UTF_8)
        end
      end

      if character.nil?
        puts "No Character #{identicals} on line:#{line_no}"
        next
      end

      result[:kanji] << character if kanji
      result[:simplified] << character if simplified
      result[:traditional] << character if traditional
    end

    results << result
  end

  results.each do |result|
    triplet = [:kanji, :simplified, :traditional].map do |type|
      if result[type].length == 0
        'N/A'
      else
        result[type].join(',')
      end
    end
    puts triplet.join("\t")
  end
end
