# frozen_string_literal: true

# (see Evideo)
module Evideo
  # parametros video :tempo, :bitrate - Duration: 01:01:08.50, start: 0.000000, bitrate: 2228 kb/s
  RE1 = /duration:\s+(\d\d:\d\d:\d\d).*bitrate:\s+(\d+)\s+kb/i
  # parametros video :height, :fps -
  #  Stream #0:0: Video: h264 (Main), yuv420p(tv, bt709, progressive), 1280x720
  #  [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1k tbn, 180k tbc (default)
  RE2 = /stream.*video:.*x\s*(\d+).*\s+(\d+\.*\d*)\s+fps/i
  # parametros video :ratio - display_aspect_ratio=16:9
  RE3 = /display_aspect_ratio\s*=\s*(\d+:\d+)$/i
  # parametros video :audio - Stream #0:1(eng): Audio: aac (LC), 48000 Hz, stereo, fltp (default)
  RE4 = /stream.*audio:.*\s+(\d+)\s+hz/i

  # permite analizar string output do comando sonda video
  class Video
    # @return [String] base ficheiro video
    attr_reader :bas
    # @return [String] extensao ficheiro video
    attr_reader :ext
    # @return [Thor::CoreExt::HashWithIndifferentAccess] opcoes trabalho
    attr_reader :ops

    # @param [String] ficheiro video a processar
    # @param [Thor::CoreExt::HashWithIndifferentAccess] opcoes trabalho
    # @option opcoes [Array<String>] :d (/home/eu/lust,/media/eu/hrv2,/media/eu/hrv2/lust) pastas onde procurar videos
    # @option opcoes [String] :i (ftv) pasta inicial dos videos
    # @option opcoes [String] :o (out) pasta final dos videos
    # @option opcoes [Boolean] :s (false) 10 segundos cortados no inicio do video final
    # @option opcoes [Integer] :t (0) segundos duracao video final 0=sem cortes
    # @return [Video] videos processados para arquivo uniformizado
    def initialize(ficheiro, opcoes)
      @ext = File.extname(ficheiro)
      @bas = File.basename(ficheiro, ext)
      @ops = opcoes
      @iopcao = {}
    end

    # @return [String] texto probe do video inicial
    def iprobe
      @iprobe ||= `#{cmd_prob(inome)}`
    end

    # @return [Array<String>] parametros video inicial [:tempo, :bitrate]
    def i1scan
      @i1scan ||= iprobe.scan(RE1).flatten
    end

    # @return [Array<String>] parametros video inicial [:height, :fps]
    def i2scan
      @i2scan ||= iprobe.scan(RE2).flatten
    end

    # @return [String] parametro video inicial :tempo hh:mm:ss
    def itempo
      @iopcao[:tempo] ||= i1scan[0] || '00:00:00'
    end

    # @return [Integer] parametro video inicial :bitrate kb/s
    def ibitrate
      @iopcao[:bitrate] ||= Integer(i1scan[1] || 0)
    end

    # @return [Integer] parametro video inicial :height
    def iheight
      @iopcao[:height] ||= Integer(i2scan[0] || 0)
    end

    # @return [Float] parametro video inicial :fps frame_rate
    def ifps
      @iopcao[:fps] ||= Float(i2scan[1] || 0)
    end

    # @return [String] parametro video inicial aspect :ratio 16:9
    def iratio
      @iopcao[:ratio] ||= iprobe.scan(RE3).flatten[0] || '0:1'
    end

    # @return [Integer] parametro video inicial :audio Hz
    def iaudio
      @iopcao[:audio] ||= Integer(iprobe.scan(RE4).flatten[0] || 0)
    end

    # @return [String] ficheiro inicial absoluto
    def inome
      "#{ops[:d][0]}/#{ops[:i]}/#{bas}#{ext}"
    end

    # @return [String] mostra dados do ficheiro video inicial
    def ishow
      "# r:#{ibitrate} h:#{iheight} #{iratio}"
    end

    # @return [Time] tempo no ruby standard library com precisao
    def self.to_t(tempo, pre = 8)
      Time.parse(tempo[0, pre])
    end

    # inicia variaveis do video final
    def oinit
      @oopcao = {}
      @oprobe = nil
      @o1scan = nil
      @o2scan = nil
    end

    # @return [String] texto probe do video final
    def oprobe
      return '' unless File.exist?(onome)

      @oprobe ||= `#{cmd_prob(onome)}`
    end

    # @return [Array<String>] parametros video final [:tempo, :bitrate]
    def o1scan
      @o1scan ||= oprobe.scan(RE1).flatten
    end

    # @return [Array<String>] parametros video final [:height, :fps]
    def o2scan
      @o2scan ||= oprobe.scan(RE2).flatten
    end

    # @return [String] parametro video final :tempo hh:mm:ss
    def otempo
      @oopcao[:tempo] ||= o1scan[0] || '00:00:00'
    end

    # @return [Integer] parametro video final :bitrate kb/s
    def obitrate
      @oopcao[:bitrate] ||= Integer(o1scan[1] || 0)
    end

    # @return [Integer] parametro video final :height
    def oheight
      @oopcao[:height] ||= Integer(o2scan[0] || 0)
    end

    # @return [Float] parametro video final :fps frame_rate
    def ofps
      @oopcao[:fps] ||= Float(o2scan[1] || 0)
    end

    # @return [String] parametro video final aspect :ratio 16:9
    def oratio
      @oopcao[:ratio] ||= oprobe.scan(RE3).flatten[0] || '0:1'
    end

    # @return [Integer] posicao array pastas onde procurar videos finais
    def pos
      # -1 #{ops[:d][0]}/#{ops[:i]}/#{ops[:o]}"
      #  0 #{ops[:d][pos]}/#{ops[:o]}"
      #  1 #{ops[:d][pos]}/#{ops[:o]}"
      @pos ||= -1
    end

    # @return [String] video final absoluto
    def onome
      dir = ops[:d]
      (pos == -1 ? "#{dir[0]}/#{ops[:i]}" : dir[pos]) + "/#{ops[:o]}/#{bas.downcase}.mp4"
    end

    # @return [String] mostra dados do ficheiro video final
    def oshow
      "# r:#{obitrate} h:#{oheight} #{oratio} #{ops[:d][pos]}/#{ops[:o]}"
    end
  end
end
