class PCMEncoder extends AudioWorkletProcessor {
  process(inputs) {
    const pcm = inputs[0][0]; // Float32Array
    if (!pcm) return true;

    // Convert to 16-bit little endian
    const buf = new Int16Array(pcm.length);
    for (let i = 0; i < pcm.length; ++i)
      buf[i] = Math.max(-1, Math.min(1, pcm[i])) * 0x7fff;

    // send 20 ms (~320 samples @16 kHz)
    this.port.postMessage(btoa(String.fromCharCode(...new Uint8Array(buf.buffer))));
    return true;
  }
}
registerProcessor("pcm-encoder", PCMEncoder);