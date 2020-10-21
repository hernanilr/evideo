# frozen_string_literal: true

require 'time'

# (see Evideo)
module Evideo
  # permite analizar string output do comando sonda video
  class Video
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
      @oopcao[:tempo] ||= (o1scan[0] || '00:00:00')
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
      @oopcao[:ratio] ||= (oprobe.scan(RE3).flatten[0] || '0:1')
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
