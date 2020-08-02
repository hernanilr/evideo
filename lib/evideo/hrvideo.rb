# frozen_string_literal: true

module Evideo
  # permite analizar string output do comando sonda video
  class HRVideo
    # @return [String] nome do ficheiro video
    attr_reader :nome
    # @return [String] extensao do ficheiro video
    attr_reader :ext
    # @return [String] base do ficheiro video
    attr_reader :base
    # @return [String] duracao do ficheiro video
    attr_reader :tempo
    # @return [String] bitrate do ficheiro video
    attr_reader :bitrate

    # Duration: 01:01:08.50, start: 0.000000, bitrate: 2228 kb/s
    R1 = /duration:\s+(\d\d:\d\d:\d\d).*bitrate:\s+(\d+)\s+kb/i.freeze
    # Stream #0:0: Video: h264 (Main), yuv420p(tv, bt709, progressive), 1280x720
    # [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1k tbn, 180k tbc (default)
    R2 = /stream.*video:.*x\s*(\d+).*\s+(\d+\.*\d*)\s+fps/i.freeze
    # display_aspect_ratio=16:9
    R3 = /display_aspect_ratio\s*=\s*(\d+:\d+)$/i.freeze
    # Stream #0:1(eng): Audio: aac (LC), 48000 Hz, stereo, fltp (default)
    # Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 127 kb/s (default)
    R4 = /stream.*audio:.*\s+(\d+)\s+hz/i.freeze

    def initialize(fil)
      @nome = fil
      @ext = File.extname(fil)
      @base = File.basename(fil, @ext).downcase
      @tempo = '00:00:00'
      @bitrate = 0
      @probe = `#{cmd_probe}` if File.exist?(fil)
      return unless @probe

      tr1 = @probe.scan(R1).flatten
      @tempo = tr1[0].to_s
      @bitrate = tr1[1].to_i
    end

    # Parametrizar height e frame rate
    def r2
      return unless @probe

      tr2 = @probe.scan(R2).flatten
      @height = tr2[0].to_i
      @fps = tr2[1].to_f
    end

    # Parametrizar aspect ratio
    def r3
      return unless @probe

      @ratio = @probe.scan(R3).flatten[0]
    end

    # Parametrizar audio
    def r4
      return unless @probe

      @audio = @probe.scan(R4).flatten[0].to_i
    end

    # @return [String] audio
    def audio
      r4 unless @audio

      @audio
    end

    # @return [String] height
    def height
      r2 unless @height

      @height
    end

    # @return [String] frame rate
    def fps
      r2 unless @fps

      @fps
    end

    # @return [String] aspect ratio
    def ratio
      r3 unless @ratio

      @ratio
    end
  end
end
