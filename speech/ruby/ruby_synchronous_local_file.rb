require 'base64'
require "google/cloud/speech"

puts "Input the filename: "
file_name = gets.chomp
audio_file_path = "../samples/audio/#{file_name}"
encoded_file_path = "../samples/base64/#{file_name.split('.')[0]}-base64"

encoded_string = Base64.encode64(File.open(audio_file_path).read)

File.open(encoded_file_path, "wb") do |file|
    file.write(Base64.decode64(encoded_string))
end


speech = Google::Cloud::Speech.new

audio_file = File.binread encoded_file_path
config     = { encoding:          :LINEAR16,
               sample_rate_hertz: 16000,
               language_code:     "en-US"   }
audio      = { content: audio_file }

response = speech.recognize config, audio

results = response.results

alternatives = results.first.alternatives
alternatives.each do |alternative|
  puts "Transcription: #{alternative.transcript}"
end
