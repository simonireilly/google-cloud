// This file should continue to stream until we force quit
//
// When the single utterance is closed it should open a new connection

const record = require('node-record-lpcm16');

// Imports the Google Cloud client library
const speech = require('@google-cloud/speech');

// Creates a client
const client = new speech.SpeechClient();

// Configure request
const encoding = 'LINEAR16';
const sampleRateHertz = 16000;
const languageCode = 'en-US';

const request = {
  config: {
    encoding: encoding,
    sampleRateHertz: sampleRateHertz,
    languageCode: languageCode,
  },
  interimResults: true, // If you want interim results, set this to true
  singleUtterance: true,
};

// Create a recognize stream
const recognizeStream = () => {
  return (
    client
    .streamingRecognize(request)
    .on('error', console.error)
    .on('data', data =>
      data.results[0] && data.results[0].alternatives[0]
      ? sendResults(data)
      : startRecording()
      )
    ).close
}

// Send the results
const sendResults = (data) => (
  process.stdout.write(`Transcription: ${data.results[0].alternatives[0].transcript}\n`)
  )

// Start recording and send the microphone input to the Speech API
const startRecording = () => {
  process.stdout.write(`Starting a new stream\n`)
  record
  .start({
    sampleRateHertz: sampleRateHertz,
    threshold: 0,
    verbose: false,
    recordProgram: 'rec',
    silence: '10.0',
  })
  .on('error', console.error)
  .pipe(recognizeStream())
}

startRecording()


console.log('Listening, press Ctrl+C to stop.');
