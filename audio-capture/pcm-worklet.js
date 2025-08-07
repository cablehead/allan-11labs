// PCM Worklet for audio capture and processing
class PCMProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.bufferSize = 4096; // Chunk size for processing
    this.buffer = new Float32Array(this.bufferSize);
    this.bufferIndex = 0;
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const channel = input[0];
    
    if (!channel) {
      return true; // Keep processor alive
    }

    // Accumulate audio data in buffer
    for (let i = 0; i < channel.length; i++) {
      this.buffer[this.bufferIndex] = channel[i];
      this.bufferIndex++;
      
      // When buffer is full, process it
      if (this.bufferIndex >= this.bufferSize) {
        this.processBuffer();
        this.bufferIndex = 0;
      }
    }
    
    return true; // Keep processor alive
  }

  processBuffer() {
    // Convert float32 PCM to int16 PCM (like ElevenLabs expects)
    const int16Buffer = new Int16Array(this.bufferSize);
    
    for (let i = 0; i < this.bufferSize; i++) {
      // Clamp to [-1, 1] and convert to 16-bit signed integer
      let sample = Math.max(-1, Math.min(1, this.buffer[i]));
      int16Buffer[i] = sample * 32767;
    }
    
    // Send the buffer to main thread
    this.port.postMessage(int16Buffer.buffer);
  }
}

registerProcessor('pcm-encoder', PCMProcessor);