# frozen_string_literal: true

require 'time'

module Evideo
  # permite analizar/processar videos para arquivo
  class HRVideo < String
    # @return [String] tempo: rate:
    def show
      return video unless @probe

      "tempo: #{duration} rate: #{bitrate}"
    end

    # Testa validade video original
    #
    # @return [true, false] sim ou nao video esta ok
    def ofok?
      return false unless (bitrate < 3000 && ext == '.mp4') ||
                          Time.parse(duration) < Time.parse('00:01:00')

      puts "rm \"#{video}\" # #{show}"
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
    # @param [String] out pasta destino dos videos
    # @return [true, false] sim ou nao <local>/<video> esta ok
    def vdok?(ary, out)
      if ary.empty? then false
      elsif vfok?(HRVideo.new("#{ary.first}/#{out}/#{base}.mp4")) then true
      else  vdok?(ary.drop(1), out)
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
      if ratio == '0:1' then bitrate < 720 ? '' : ' -aspect 16:9'
      else                   " -aspect #{ratio}"
      end
    end

    # @return [String] video dimensions comando conversao
    def dimension
      if    bitrate <  480 then ' -s hd480'
      elsif bitrate <= 720 then ' -s hd720'
      else                      ' -s hd1080'
      end
    end

    # @return [String] comando analise
    def probe
      "ffprobe -hide_banner -show_streams \"#{video}\" 2>&1|grep -v title"
    end

    # @return [String] comando conversao
    def mpeg
      "ffmpeg #{geral} -i \"#{video}\" -y -an " +
        # framerate & bitrate
        "-r #{[fps, 25].min} -b:v #{[bitrate, 2000].min}k" +
        dimension + aspect +
        ' -metadata title= -metadata artist= -metadata comment=' \
        ' -metadata major_brand= -metadata compatible_brands=' +
        # para teste produz somente segundos
        # ' -t 20' \
        ''
    end

    # Processa videos
    #
    # @param [Array<String>] dar locais onde procurar videos
    # @param [String] out pasta destino dos videos
    # @param [String] din pasta origem dos videos
    def processa(dar, out, din)
      return if ofok? || vdok?(dar, out)

      system mpeg + " #{din}/#{out}/#{base}.mp4"
      vfok?(HRVideo.new("#{din}/#{out}/#{base}.mp4"))
    end

    # Testa videos
    #
    # @param [Array<String>] dar locais onde procurar videos
    # @param [String] out pasta destino dos videos
    def testa(dar, out)
      return if ofok? || vdok?(dar, out)

      puts "ls \"#{video}\" # #{show}"
    end
  end
end
