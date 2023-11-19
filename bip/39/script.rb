#!/usr/bin/env ruby

require 'digest'

class String
  def first_four_letters
    self[0,4]
  end
end

class Mnemonic

  def initialize(dictionary, words)
    @three_bits  = ["000", "001", "010", "011", "100", "101", "110", "111"]
    @dictionary  = dictionary
    @words       = words
    @entropy_253 = entropy_253_compute()
    @checksums   = checksums_compute()
    @last_words  = last_words_compute()
  end

  def dictionary()
    puts "#{@dictionary}"
  end

  def words()
    puts "#{@words}"
  end

  def entropy()
    puts "#{@entropy_253}"
  end

  def checksums()
    puts "-------------------------------"
    @checksums.each do |three_bits, h|
      puts "-- With the three bits : #{three_bits} -- "
      h.each_pair {|key, value| puts " - #{key}: #{value}" }
    end
  end

  def last_words()
    puts "#{@last_words}"
  end

  private

  def last_words_compute
    words = []
    @checksums.each_pair { |three_bits, h|  words.push(h[:Last_Word]) }
    return words
  end

  def entropy_253_compute
    entropy_253 = ""
    for word in @words
      index = @dictionary.index(word)
      binary_index = index.to_s(2)
      # add 0 * n if binary_index number if under 11
      binary_index =  ("0" * (11 - binary_index.length)).concat(binary_index)
      #puts " - #{word} index : #{index}"
      #puts " - index in decimal format #{binary_index}"
      entropy_253.concat(binary_index)
    end

    return entropy_253
  end

  def checksums_compute

    h_all = {}
    for bits in @three_bits
      h = {}
      entropy = @entropy_253 + bits
      ##puts "3 bits = #{bits}"
      ##puts "entropy = #{entropy}"
      ##puts "entropy LENGTH = #{entropy.length}"
      sha256 = Digest::SHA256.digest([entropy].pack("B*")) # hash of entropy (in raw binary)
      ##puts "sha256 #{sha256.unpack("H*")}"
      ##puts "Two digits from hash = #{sha256.unpack("H*")[0][0,2]}"
      cs = sha256.unpack("H*")[0][0,2]
      cs_binary = cs.hex.to_s(2)
      cs_binary = ("0" * (8 - cs_binary.length)).concat(cs_binary)
      ##puts "binary from 2 digits from hash = #{cs_binary}"
      binary_seed = entropy + cs_binary
      ###puts "binary_seed = |#{binary_seed}|"
      binary_seed_split = binary_seed.scan(/[0-1]{11}/)
      ###puts "binary seed split = #{binary_seed_split}"

      word_indexes = binary_seed_split.clone
      word_list = binary_seed_split.clone

      h[:Raw_Binary]        = entropy.scan(/[0-1]{11}/).join(" ") + " #{bits}"
      #h[:sha256]            = sha256.unpack("H*")
      #h[:cs]                = cs
      h[:Binary_checksum]   = cs_binary
      #h[:binary_seed]       = binary_seed
      #h[:binary_seed_split] = binary_seed_split
      h[:Word_Indexes]      = word_indexes.each_index { |index| word_indexes[index] = word_indexes[index].to_i(2) }
      h[:Words_List]        = word_list.each_index { |index| word_list[index] = @dictionary[word_indexes[index]] }
      h[:Last_Word]         = h[:Words_List][-1]

      h_all["#{bits}"] = h
    end

    return h_all
  end

end


def check words
  # check the 23 words if given via commandline argument
  if words.length != 23
    puts "Missing argument, 23 words is needed but #{words.length} given !"
    exit(1)
  end

  if ! File.exist?('english.txt')
    puts "The file 'english.txt' with BIP39 english dictionary is not present !"
    exit(2) 
  end

  # check if word are from the english dictionary
  file = File.open("english.txt")
  dictionary = file.readlines.map(&:chomp)
  for word in words
    if ! dictionary.include? word
      puts "The word #{word} is not included in the dictionary !"
      exit(3)
    end
  end

  return dictionary
end

#
#  MAIN
#

def main words
  words = ARGV
  dictionary = check words
  seed = Mnemonic.new(dictionary = dictionary, words = words)
  #seed.words()
  #puts "entropy : "
  #seed.entropy()
  #puts "checksums : "
  #seed.checksums()
  #puts "--- last words list ---"
  seed.last_words()
end

main ARGV
