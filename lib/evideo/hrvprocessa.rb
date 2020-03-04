# frozen_string_literal: true

require 'time'

module Evideo
  # permite analizar/processar videos para arquivo
  class HRVideo < String
    # @return [String] tempo: rate:
    def show
      return video unless @probe

      "tempo: #{duration} rate: #{bitrate} ratio: #{ratio} height: #{height}"
    end

    # Testa validade video original
    #
    # @param [String] aot pasta destino dos videos absoluta
    # @return [true, false] sim ou nao video esta ok
    def ofok?(aot)
      return false unless (bitrate < 3000 && ext == '.mp4') ||
                          Time.parse(duration) < Time.parse('00:01:00')
      return false unless ratio == '16:9' && height > 480

      puts "mv \"#{video} #{aot}/#{base}.mp4\" # #{show}"
      true
    end

    # Testa validade video processado contra video original
    #
    # @param [String] file video processado a testar validade
    # @return [true, false] sim ou nao video esta ok
    def vfok?(file)
      return false unless File.exist?(file.video) &&
                          file.bitrate < 3000 &&
                          Time.parse(file.duration) > Time.parse(duration) - 60

      puts "rm \"#{video}\" # #{file.video} #{file.show}"
      true
    end

    # Testa validade videos processados em todos locais contra video original
    #
    # @param [Array<String>] ary array locais onde procurar videos
    # @param [String] pot pasta destino dos videos
    # @return [true, false] sim ou nao <local>/<video> esta ok
    def vdok?(ary, pot)
      if ary.empty? then false
      elsif vfok?(HRVideo.new("#{ary.first}/#{pot}/#{base}.mp4")) then true
      else  vdok?(ary.drop(1), pot)
      end
    end

    # @return [String] opcoes gerais comando conversao
    def geral
      '-loglevel quiet -hide_banner' +
        # para ignorar segundos no inicio
        # ' -ss 15' \
        ''
    end

    # @return [String] aspect ratio comando conversao
    def aspect
      if ratio == '0:1' then height < 720 ? '' : ' -aspect 16:9'
      else                   " -aspect #{ratio}"
      end
    end

    # @return [String] video dimensions comando conversao
    def dimension
      if    height <  480 then ' -s hd480'
      elsif height <= 720 then ' -s hd720'
      else                     ' -s hd1080'
      end
    end

    # @return [String] comando analise
    def probe
      "ffprobe -hide_banner -show_streams \"#{video}\" 2>&1|grep -v title"
    end

    # Comando para processar videos
    #
    # @param [String] tempo do video processato
    # @return [String] comando conversao
    def mpeg(tempo)
      "ffmpeg #{geral} -i \"#{video}\" -y -an " +
        # framerate & bitrate
        "-r #{[fps, 25].min} -b:v #{[bitrate, 2000].min}k" +
        dimension + aspect +
        ' -metadata title= -metadata artist= -metadata comment=' \
        ' -metadata major_brand= -metadata compatible_brands=' +
        # para teste produz somente segundos
        tempo
    end

    # Processa videos
    #
    # @param [Hash] opcoes parametrizacao
    # @option opcoes [Array<String>] :d locais onde procurar videos
    # @option opcoes [<String>] :i pasta origem dos videos
    # @option opcoes [<String>] :o pasta destino dos videos
    # @option opcoes [<Boolean>] :t processa somente segundos para teste
    # @param [String] aot pasta destino dos videos absoluta
    def processa(opcoes, aot)
      return if ofok?(aot) || vdok?(opcoes[:d], opcoes[:o])

      system mpeg(opcoes[:t] ? ' -t 20' : '') + " #{aot}/#{base}.mp4"
      vfok?(HRVideo.new("#{aot}/#{base}.mp4"))
    end

    # Testa videos
    #
    # @param [Hash] opcoes parametrizacao
    # @option opcoes [Array<String>] :d locais onde procurar videos
    # @option opcoes [<String>] :i pasta origem dos videos
    # @option opcoes [<String>] :o pasta destino dos videos
    # @option opcoes [<Boolean>] :t processa somente segundos para teste
    # @param [String] aot pasta destino dos videos absoluta
    def testa(opcoes, aot)
      return if ofok?(aot) || vdok?(opcoes[:d], opcoes[:o])

      puts "ls \"#{video}\" # #{show}"
    end
  end
end
