using System;
using System.IO;
using System.Text;

// Esta clase es una utilidad independiente para generar un efecto de sonido sin necesidad de descargar archivos externos.
// Genera un archivo "hit.wav" con un sonido estilo 8-bits de impacto.
public class WavGenerator
{
    public static void Main()
    {
        string filePath = "assets/hit.wav"; // Ruta de salida
        
        // Configuración básica del audio
        int sampleRate = 44100; // Calidad estándar (CD)
        short bitsPerSample = 16;
        short channels = 1;     // Mono
        int durationMs = 200;   // Duración corta (0.2 segundos) para un golpe seco
        
        // Cálculos para el tamaño del archivo
        int numSamples = (sampleRate * durationMs) / 1000;
        int dataSize = numSamples * channels * (bitsPerSample / 8);
        int fileSize = 36 + dataSize; // Cabecera (36 bytes) + Datos

        // Crear el archivo binario
        using (FileStream fs = new FileStream(filePath, FileMode.Create))
        using (BinaryWriter bw = new BinaryWriter(fs))
        {
            // --- Escribir CABECERA WAV (RIFF) ---
            // Esto es necesario para que cualquier reproductor entienda el archivo
            bw.Write(Encoding.ASCII.GetBytes("RIFF"));
            bw.Write(fileSize);
            bw.Write(Encoding.ASCII.GetBytes("WAVE"));

            // --- Chunk de Formato (fmt) ---
            bw.Write(Encoding.ASCII.GetBytes("fmt "));
            bw.Write(16); // Tamaño del chunk
            bw.Write((short)1); // Audio formato (1 = PCM sin compresión)
            bw.Write(channels);
            bw.Write(sampleRate);
            bw.Write(sampleRate * channels * (bitsPerSample / 8)); // Byte rate (velocidad de datos)
            bw.Write((short)(channels * (bitsPerSample / 8))); // Alineación de bloques
            bw.Write(bitsPerSample);

            // --- Chunk de Datos (data) ---
            bw.Write(Encoding.ASCII.GetBytes("data"));
            bw.Write(dataSize);

            // --- Generación del Sonido (Síntesis) ---
            // Creamos una onda cuadrada que baja de tono para simular un impacto
            Random rand = new Random();
            for (int i = 0; i < numSamples; i++)
            {
                double time = (double)i / sampleRate;
                
                // Efecto de caída de tono (Pitch Slide): de 400Hz a 100Hz
                double freq = 400.0 - (300.0 * (double)i / numSamples);
                short amplitude = 10000; // Volumen
                
                // Generar Onda Cuadrada (Square Wave) típica de juegos retro
                // Si el seno es positivo, valor máximo; si es negativo, valor mínimo.
                short sample = (short)(Math.Sin(2 * Math.PI * freq * time) > 0 ? amplitude : -amplitude);
                
                // Añadir un poco de "ruido" aleatorio para darle textura crujiente
                if (rand.NextDouble() > 0.8) sample = (short)(sample * 0.8);

                bw.Write(sample);
            }
        }
        
        // Nota: Este archivo se ejecuta manualmente una vez para crear el asset, no es parte del juego en tiempo real.
    }
}

