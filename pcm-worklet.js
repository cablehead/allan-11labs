class PCMEncoder extends AudioWorkletProcessor {
  constructor() {
    super();
    this.frameCount = 0;
  }
  
  process(inputs) {
    const pcm = inputs[0][0]; // Float32Array
    this.frameCount++;
    
    // Debug: log first few frames and periodically
    if (this.frameCount <= 5 || this.frameCount % 160 === 0) { // every ~1 second at 16kHz
      const hasAudio = pcm && pcm.length > 0;
      const rms = hasAudio ? Math.sqrt(pcm.reduce((sum, val) => sum + val * val, 0) / pcm.length) : 0;
      console.debug(`🎙️ Frame #${this.frameCount}: ${pcm?.length || 0} samples, RMS: ${rms.toFixed(4)}`);
    }
    
    if (!pcm || pcm.length === 0) {
      console.debug("⚠️ No audio input data");
      return true;
    }

    // Convert to 16-bit little endian
    const buf = new Int16Array(pcm.length);
    for (let i = 0; i < pcm.length; ++i)
      buf[i] = Math.max(-1, Math.min(1, pcm[i])) * 0x7fff;

    // send 20 ms (~320 samples @16 kHz)
    const b64 = btoa(String.fromCharCode(...new Uint8Array(buf.buffer)));
    this.port.postMessage(b64);
    return true;
  }
}
registerProcessor("pcm-encoder", PCMEncoder);