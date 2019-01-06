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

audio_content  = File.binread audio_file_path
bytes_total    = audio_content.size
bytes_sent     = 0
chunk_size     = 32000

streaming_config = {config: {encoding:                :LINEAR16,
                             sample_rate_hertz:       16000,
                             language_code:           "en-US",
                             enable_word_time_offsets: true     },
                    interim_results: true}

stream = speech.streaming_recognize streaming_config

# Simulated streaming from a microphone
# Stream bytes...
while bytes_sent < bytes_total do
  stream.send audio_content[bytes_sent, chunk_size]
  bytes_sent += chunk_size
  sleep 1
end

puts "Stopped passing"
stream.stop

# Wait until processing is complete...
stream.wait_until_complete!

results = stream.results

alternatives = results.first.alternatives
alternatives.each do |result|
  puts "Transcript: #{result.transcript}"
end
