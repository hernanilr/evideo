# frozen_string_literal: true

# (see Evideo)
module Evideo
  # aspect ratios a converter para 16:9
  ART = ['0:1', '4:3'].freeze

  # classe permite analizar/processar videos para arquivo uniformizado
  class Video
    # processa video - somente se necessario
    def processa
      return if ivideo? || opastas?

      work(cmd_mpeg("#{ops[:d][0]}/#{ops[:i]}/#{ops[:o]}/#{bas.downcase}"))
    end

    # executa/mostra comando mpeg
    # @param [String] cmd comando mpeg
    def work(cmd)
      if ops[:x]
        puts("processar #{inout}")
        system(cmd)
      else
        puts(cmd)
      end
    end

    # @return [String] params video inicial & comando mpeg
    def inout
      "#{bas}#{ishow} OUT: #{fparams}"
    end

    # @return [true, false] video inicial ok
    def ivideo?
      return false if ext != '.mp4' || iaudio.positive? || ibitrate >= 3000 || iheight <= 480

      puts("mv #{inome} #{onome} #{ishow}")
      true
    end

    # @return [true, false] video final ok
    def ovideo?
      oinit
      return false if Video.to_t(otempo, 5) != Video.to_t(itempo, 5) || obitrate >= 3000 || oheight < 480

      puts("rm #{inome} #{oshow}")
      true
    end

    # @return [true, false] pastas com video final ok
    def opastas?
      ary = ops[:d]
      if pos == ary.size then false elsif ovideo? then true else
                                                              # proxima pasta
                                                              @pos += 1
                                                              opastas?
      end
    end

    # @return [String] parametros do comando processar video
    def fparams
      # frame rate & bitrate & dimensions & aspect ratio
      "-r #{[ifps, 25.0].min} -b:v #{[ibitrate, 2000].min}k#{fdimensions}#{fratio}"
    end

    # @note final video dimensions hd480=852x480, hd720=1280x720, hd1080=1920x1080
    # @return [String] dimensions do comando processar video
    def fdimensions
      if iheight < 480
        ' -s hd480'
      elsif iheight <= 720
        ' -s hd720'
      else
        ' -s hd1080'
      end
    end

    # @return [String] aspect ratio do comando processar video
    def fratio
      ART.include?(iratio) ? " -aspect 16:9 -filter:v 'pad=max(iw\\,ih*16/9):ih:(ow-iw)/2:(oh-ih)/2'" : ''
    end

    # @return [String] cortes inicio video & duracao do video final processado
    def fcuts
      ict = Integer(ops[:s])
      fct = Integer(ops[:t])
      "#{ict.positive? ? " -ss #{ict}" : ''}#{fct.positive? ? " -t #{fct}" : ''}"
    end

    # @param [String] ficheiro video
    # @return [String] comando probe
    def cmd_prob(ficheiro)
      "ffprobe -hide_banner -show_streams #{ficheiro} 2>&1|grep -v title"
    end

    # @param [String] base ficheiro video final
    # @return [String] comando mpeg
    def cmd_mpeg(base)
      oout = "#{base}.out"
      "ffmpeg -loglevel quiet -hide_banner -i #{inome} -y -an #{fparams}#{fcuts} " \
        '-metadata title= -metadata artist= -metadata comment= -metadata major_brand= -metadata compatible_brands= ' \
        "#{base}.mp4 >#{oout} 2>&1;[ -s #{oout} ] || rm #{oout}"
    end
  end
end
