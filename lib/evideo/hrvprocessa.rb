# frozen_string_literal: true

require 'time'

module Evideo
  # permite analizar/processar videos para arquivo
  class HRVideo < String
    # Testa validade video
    #
    # @param [String] file video a testar validade
    # @return [true, false] sim ou nao video esta ok
    def vfok?(file)
      return false unless File.exist?(file.video)

      # tempo video processado < tempo original -60 segundos ou
      # bitrate video processado > bitrate video origunal
      return false unless Time.parse(file.duration) >
                          Time.parse(duration) - 60 &&
                          file.bitrate < 3000

      puts "rm #{video} # #{file.rm_show}"
      true
    end

    # Testa validade <locais>/<video>
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

    # @return [String] metadata comando conversao
    def metadata
      ' -metadata title= -metadata artist= -metadata comment=' \
        ' -metadata major_brand= -metadata compatible_brands=' +
        # para teste produz somente segundos
        # ' -t 20' \
        ''
    end

    # @return [String] aspect ratio comando conversao
    def aspect_ratio
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
      "ffmpeg #{geral} -i #{video} -y -an " +
        # framerate & bitrate
        "-r #{[fps, 25].min} -b:v #{[bitrate, 2000].min}k" +
        dimension + aspect_ratio + metadata
    end

    # Processa video
    #
    # @param [Array<String>] dar locais onde procurar videos
    # @param [String] din pasta origem dos videos
    # @param [String] out pasta destino dos videos
    def processa(dar, din, out)
      return if (bitrate < 3000 && ext == '.mp4') ||
                Time.parse(duration) < Time.parse('00:01:00') ||
                vdok?(dar, out)

      system mpeg + " #{din}/#{out}/#{base}.mp4"
      vfok?(HRVideo.new("#{din}/#{out}/#{base}.mp4"))
    end

    # @return [String] video: tempo: rate:
    def rm_show
      return video unless @probe

      "#{video} tempo: #{duration} rate: #{bitrate} "
    end

    # @return [String] video: tempo: rate: y: framerate: ratio:
    def testa
      return video unless @probe

      "#{base}#{ext} tempo: #{duration} rate: #{bitrate} " \
        "y: #{height} framerate: #{fps} ratio: #{ratio}"
    end
  end
end
