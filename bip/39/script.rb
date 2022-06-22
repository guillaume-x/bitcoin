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
    @checksums    = checksums_compute()
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
    puts "#{@checksums}"
  end

  private

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

    for bits in @three_bits
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
      tab = Array.new
      for binary in binary_seed_split
        #puts "#{binary} = #{binary.to_i(2)}"
        tab.push(@dictionary[binary.to_i(2)])
      end
      ###puts "tab = #{tab}"
    end

    return tab
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
  seed.words()
  seed.entropy()
  seed.checksums()
end

main ARGV
exit











# print word list given
puts "Word list : "
for word in ARGV
  puts " - #{word}"
end

# print first 4 characters from each word
puts "Word list : "
for word in ARGV
  puts " - #{word.first_four_letters}"
end

# compute each word with :
# - get index number of the words from the dictionary
# - compute each index number into binary
# - make the entropy = concat(index number in binary format)
ENTROPY = ""

puts "entropy = #{ENTROPY}"
puts "entropy LENGTH = #{ENTROPY.length}"

for bits in three_bits
  puts "-------------------------------------"
  entropy = ENTROPY
  entropy = entropy + bits
  #entropy = entropy
  puts "3 bits = #{bits}"
  puts "entropy = #{entropy}"
  puts "entropy LENGTH = #{entropy.length}"
  sha256 = Digest::SHA256.digest([entropy].pack("B*")) # hash of entropy (in raw binary)
  puts "sha256 #{sha256.unpack("H*")}"
  puts "Two digits from hash = #{sha256.unpack("H*")[0][0,2]}"
  cs = sha256.unpack("H*")[0][0,2]
  cs_binary = cs.hex.to_s(2)
  cs_binary = ("0" * (8 - cs_binary.length)).concat(cs_binary)
  puts "binary from 2 digits from hash = #{cs_binary}"
  binary_seed = entropy + cs_binary
  binary_seed_split = binary_seed.scan(/.{0,11}/)
  puts "binary seed split = #{binary_seed_split}"
  tab = Array.new
  for binary in binary_seed_split
    puts "#{binary} = #{binary.to_i(2)}"
    tab.push(dictionary[binary.to_i(2)])
  end
  puts "tab = #{tab}" 
end


exit

entropy = "1011110111001011101101000001010001011001011010100101101111011110101000110101100011111000000011111010111011100110010100110101001101100110101101001001010011001111100101010110000111110101001110111101110011110010110001011001011111011001001010010110111111100111"

# 1. Create checksum
require 'digest'
size = entropy.length / 32 # number of bits to take from hash of entropy (1 bit checksum for every 32 bits entropy)
sha256 = Digest::SHA256.digest([entropy].pack("B*")) # hash of entropy (in raw binary)
checksum = sha256.unpack("B*").join[0..size-1] # get desired number of bits
#check = Digest::SHA256.hexdigest([entropy].pack("B*"))
entropy_pack = [entropy].pack("B*")
sha256hex = sha256.unpack("H*")
puts "entropy.pack : #{entropy_pack}"
puts "sha256hex: #{sha256hex}"
puts "checksum: #{checksum}"

# 2. Combine
full = entropy + checksum
puts "combined: #{full}"

# 3. Split in to strings of of 11 bits
pieces = full.scan(/.{11}/)
puts "--------------"
puts pieces

