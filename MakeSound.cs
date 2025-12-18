using System;
using System.IO;
using System.Text;

public class WavGenerator
{
    public static void Main()
    {
        string filePath = "assets/hit.wav";
        int sampleRate = 44100;
        short bitsPerSample = 16;
        short channels = 1;
        int durationMs = 200; // 0.2 seconds impact
        int numSamples = (sampleRate * durationMs) / 1000;
        int dataSize = numSamples * channels * (bitsPerSample / 8);
        int fileSize = 36 + dataSize;

        using (FileStream fs = new FileStream(filePath, FileMode.Create))
        using (BinaryWriter bw = new BinaryWriter(fs))
        {
            // RIFF header
            bw.Write(Encoding.ASCII.GetBytes("RIFF"));
            bw.Write(fileSize);
            bw.Write(Encoding.ASCII.GetBytes("WAVE"));

            // fmt chunk
            bw.Write(Encoding.ASCII.GetBytes("fmt "));
            bw.Write(16); // Chunk size
            bw.Write((short)1); // Audio format (1 = PCM)
            bw.Write(channels);
            bw.Write(sampleRate);
            bw.Write(sampleRate * channels * (bitsPerSample / 8)); // Byte rate
            bw.Write((short)(channels * (bitsPerSample / 8))); // Block align
            bw.Write(bitsPerSample);

            // data chunk
            bw.Write(Encoding.ASCII.GetBytes("data"));
            bw.Write(dataSize);

            // Data (Square wave/Noise lowering pitch for impact effect)
            Random rand = new Random();
            for (int i = 0; i < numSamples; i++)
            {
                double time = (double)i / sampleRate;
                // Simple frequency slide down
                double freq = 400.0 - (300.0 * (double)i / numSamples);
                short amplitude = 10000;
                
                // Square wave
                short sample = (short)(Math.Sin(2 * Math.PI * freq * time) > 0 ? amplitude : -amplitude);
                
                // Add some noise for 8-bit feel
                if (rand.NextDouble() > 0.8) sample = (short)(sample * 0.8);

                bw.Write(sample);
            }
        }
    }
}
