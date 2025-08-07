// PCM Worklet for audio capture and processing
class PCMProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.bufferSize = 4096; // Chunk size for processing
    this.buffer = new Float32Array(this.bufferSize);
    this.bufferIndex = 0;
    this.processCount = 0;
    this.lastDebugTime = 0;
  }

  process(inputs, outputs, parameters) {
    const input = inputs[0];
    const channel = input[0];
    
    this.processCount++;
    
    // Debug logging every few seconds
    const now = currentTime;
    if (now - this.lastDebugTime > 2) {
      this.port.postMessage({
        type: 'debug',
        message: `Worklet process #${this.processCount}: input=${!!input}, channel=${!!channel}, length=${channel?.length || 0}`
      });
      this.lastDebugTime = now;
    }
    
    if (!channel || channel.length === 0) {
      return true; // Keep processor alive
    }

    // Check for non-zero audio data
    let hasAudio = false;
    let maxSample = 0;
    for (let i = 0; i < channel.length; i++) {
      const sample = Math.abs(channel[i]);
      if (sample > 0.001) hasAudio = true; // Threshold for noise floor
      maxSample = Math.max(maxSample, sample);
    }
    
    // Debug audio levels
    if (now - this.lastDebugTime > 2 && hasAudio) {
      this.port.postMessage({
        type: 'debug',
        message: `Audio detected! Max sample: ${maxSample.toFixed(4)}`
      });
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
    // Check if buffer has any real audio
    let nonZeroSamples = 0;
    let maxSample = 0;
    
    for (let i = 0; i < this.bufferSize; i++) {
      const sample = Math.abs(this.buffer[i]);
      if (sample > 0.001) nonZeroSamples++;
      maxSample = Math.max(maxSample, sample);
    }
    
    // Debug buffer contents
    this.port.postMessage({
      type: 'debug',
      message: `Buffer processed: ${nonZeroSamples}/${this.bufferSize} non-zero samples, max: ${maxSample.toFixed(4)}`
    });
    
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